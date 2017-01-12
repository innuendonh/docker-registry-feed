package innylibs

import io.vertx.core.Vertx
import io.vertx.ext.web.Router
import io.vertx.core.http.HttpMethod
import com.rometools.rome.feed.synd.SyndFeedImpl
import io.vertx.core.buffer.Buffer
import java.io.StringWriter
import io.vertx.core.streams.Pump
import io.vertx.core.http.HttpClientOptions
import com.google.common.base.Preconditions

class EntryPoint {

	def static void main(String[] args) {
		val vertx = Vertx.vertx
		vertx.example3
		println("Listening...")
	}

	def static example1(Vertx vertx) {
		val server = vertx.createHttpServer();
		server.requestHandler [ request |
			// This handler gets called for each request that arrives on the server
			request.response() => [
				putHeader("content-type", "text/plain")
				// Write to the response and end it
				end("Hello World!")
			]
		]
		server.listen(8080);
	}

	def static example2(Vertx vertx) {
		val server = vertx.createHttpServer();

		val router = Router.router(vertx);

		router.route().handler [
			// This handler will be called for every request
			response() => [
				putHeader("content-type", "text/plain");
				// Write to the response and end it
				end("Hello World from Vert.x-Web!");
			]
		]

		server.requestHandler[router.accept(it)].listen(8080)
	}

	def static example3(Vertx vertx) {
		val server = vertx.createHttpServer()

		val router = Router.router(vertx);

//		router.route().handler [
//			// This handler will be called for every request
//			response() => [
//				putHeader("content-type", "text/plain");
//				// Write to the response and end it
//				end("Hello World from Vert.x-Web!");
//			]
//		]
		val route1 = router.route("/some/path/").handler [ routingContext |

			val response = routingContext.response();
			// enable chunked responses because we will be adding data as
			// we execute over other handlers. This is only required once and
			// only if several handlers do output.
			response.setChunked(true);

			response.write("route1\n");

			// Call the next matching route after a 5 second delay
			routingContext.vertx().setTimer(5000, [routingContext.next()]);
		]

		val route2 = router.route("/some/path/").handler [ routingContext |

			val response = routingContext.response();
			response.write("route2\n");

			// Call the next matching route after a 5 second delay
			routingContext.vertx().setTimer(5000, [routingContext.next()]);
		]

		val route3 = router.route("/some/path/").handler [ routingContext |

			val response = routingContext.response();
			response.write("route3");

			// Now end the response
			routingContext.response().end();
		]

		val route4 = router.route(HttpMethod.GET, "/catalogue/products/:producttype/:productid/");

		route4.handler [ routingContext |
			println("Enetered route4")
			val productType = routingContext.request().getParam("producttype");
			val productID = routingContext.request().getParam("productid");

			routingContext.response => [
				putHeader("content-type", "text/plain");
				end('''You requested product type «productType» with ID «productID»''');
			]

		// Do something with them...
		]
		
		router.route("/feed").handler[
			println("Got request" + request.uri)
			response => [
				val w = new StringWriter()
				FeedWriter.writeFeed(w)
				end(w.toString)
				w.close()
			]
		]
		
		
		val client = vertx.createHttpClient(new HttpClientOptions() => [
			logActivity = true
		])
		
		router.route("/feed2").handler[ctx|
			println("Got request" + ctx.request.uri)
			ctx.response.chunked = true
			Preconditions.checkState(server.actualPort == 8080)
			client.getNow(server.actualPort, "localhost", "/feed")[
				//bodyHandler[buf|ctx.response.end(buf)]
				//handler[buf|ctx.response.write(buf)]
				endHandler[ctx.response.end()]
				Pump.pump(it, ctx.response).start()
			]
//			client.get(server.actualPort, "localhost", "/feed")[
//				endHandler = [ctx.response.end()]
//				Pump.pump(it, ctx.response).start()
//			]
		]

		server.requestHandler[router.accept(it)].listen(8080)
	}

}
