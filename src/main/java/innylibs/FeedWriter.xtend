package innylibs

import com.rometools.rome.feed.synd.*
import com.rometools.rome.io.SyndFeedOutput
import java.io.FileWriter
import java.io.Writer
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.ArrayList
import java.util.List
import java.io.OutputStreamWriter

/** 
 * It creates a feed and writes it to a file.
 * <p>
 */
class FeedWriter {
	static final DateFormat DATE_PARSER = new SimpleDateFormat("yyyy-MM-dd")

	def static void main(String[] args) {
		var boolean ok = false
//		if (args.length === 2) {
		try {
			val String feedType = "atom_0.3" // args.get(0)
			val String fileName = null // args.get(1)
			var Writer writer = new OutputStreamWriter(System.out);
			writeFeed(writer)
			// writer.close()
			System.out.println('''The feed has been written to the file [«fileName»]''')
			ok = true
		} catch (Exception ex) {
			ex.printStackTrace()
			System.out.println('''ERROR: «ex.getMessage()»''')
		}

		// }
		if (!ok) {
			System.out.println()
			System.out.println("FeedWriter creates a RSS/Atom feed and writes it to a file.")
			System.out.println("The first parameter must be the syndication format for the feed")
			System.out.println("  (rss_0.90, rss_0.91, rss_0.92, rss_0.93, rss_0.94, rss_1.0 rss_2.0 or atom_0.3)")
			System.out.println("The second parameter must be the file name for the feed")
			System.out.println()
		}
	}

	def static createFeed() {
		var SyndFeed feed = new SyndFeedImpl() => [
			feedType = "atom_0.3"
			title = "Sample Feed (created with ROME)"
			link = "http://rome.dev.java.net"
			description = "This feed has been created using ROME (Java syndication utilities)"
		]

		feed.entries = #[
			new SyndEntryImpl() => [
				title = "ROME v1.0"
				link = "http://wiki.java.net/bin/view/Javawsxml/Rome01"
				publishedDate = DATE_PARSER.parse("2004-06-08")
				description = new SyndContentImpl() => [
					type = "text/plain"
					value = "Initial release of ROME"
				]
			],
			new SyndEntryImpl() => [
				title = "ROME v2.0"
				link = "http://wiki.java.net/bin/view/Javawsxml/Rome02"
				publishedDate = DATE_PARSER.parse("2004-06-16")
				description = new SyndContentImpl() => [
					type = "text/plain"
					value = "Bug fixes, minor API changes and some new features"
				]
			],
			new SyndEntryImpl() =>
				[
					title = "ROME v3.0"
					link = "http://wiki.java.net/bin/view/Javawsxml/Rome03"
					publishedDate = DATE_PARSER.parse("2004-07-27")

					description = new SyndContentImpl() =>
						[
							type = "text/html"
							value = '''<p>More Bug fixes, mor API changes, some new features and some Unit testing</p><p>For details check the <a href="https://rometools.jira.com/wiki/display/ROME/Change+Log#ChangeLog-Changesmadefromv0.3tov0.4">Changes Log</a></p>'''
						]
				]
		]
		return feed
	}

	def static writeFeed(Writer writer) {
		var SyndFeedOutput output = new SyndFeedOutput()
		output.output(createFeed(), writer)
	}
}
