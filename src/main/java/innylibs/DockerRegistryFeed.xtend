package innylibs

import com.google.common.base.Preconditions
import io.vertx.core.AbstractVerticle
import io.vertx.core.Vertx
import io.vertx.core.http.HttpClientOptions
import io.vertx.core.http.HttpMethod
import io.vertx.ext.web.Router
import io.vertx.ext.web.handler.LoggerHandler
import io.vertx.core.json.JsonArray

class DockerRegistryFeed extends AbstractVerticle {

	def static void main(String[] args) {
		Vertx.vertx.deployVerticle(DockerRegistryFeed.name)
	}

	override start() {
		val server = vertx.createHttpServer();
		val client = vertx.createHttpClient(new HttpClientOptions() => [
			logActivity = true
			ssl = true
			defaultPort = 443
		])
		val router = Router.router(vertx) => [
			route().handler = LoggerHandler.create()
			route(HttpMethod.GET, "/:group/:image").handler [ ctx |
				Preconditions.checkArgument(#["group", "image"].forall[ctx.request.params.contains(it)],
					"Parameters not specified")
				val group = ctx.request.getParam("group")
				val image = ctx.request.getParam("image")
				// https://auth.docker.io/token?service=registry.docker.io&scope=repository:library/ubuntu:pull				
				client.getNow(
					"auth.docker.io", '''/token?service=registry.docker.io&scope=repository:«group»/«image»:pull''') [
					bodyHandler[buf|
						ctx.response => [answer|
							answer.putHeader("content-type", "application/json")
							val token = buf.toJsonObject().getString("token")
							
							//curl -sSL -H "Authorization: Bearer $token" "https://registry-1.docker.io/v2/library/ubuntu/manifests/xenial" | jq
							client.get("registry-1.docker.io",'''/v2/«group»/«image»/tags/list''')[
								bodyHandler[tagsBuf|
									val tagList = tagsBuf.toJsonObject
									println(tagList.getJsonArray("tags", new JsonArray).join("; "))
									answer.end(tagList.encodePrettily)
								]
							].putHeader("Authorization", '''Bearer «token»''').end()
						]
					]
				]

			]
		]
		server.requestHandler[router.accept(it)].listen(8080)
	}
}
