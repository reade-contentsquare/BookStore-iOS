#!/usr/bin/python
import re
import os
import json
from http.server import BaseHTTPRequestHandler, HTTPServer
try:
    from urllib.parse import urlparse
except ImportError:
     from urlparse import urlparse
class HttpHandler(BaseHTTPRequestHandler):
    headers = ''
    body = ''
    def do_GET(self):
        pass
    def do_POST(self):
        print("\r\n***************** POST request received: " + self.path)
        headers = self.headers
        body = self.body
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        try:
            print("headers recieved :\r\n %s \r\n" % headers)
            print("body :\r\n %s \r\n" % body)
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            print("--------data reveived--------")
            print(json.dumps(json.loads(post_data), indent=4, sort_keys=True))
            __location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))
            sdk_log_file = 'app_logs' + "/" + 'log.txt'
            print(__location__ + "/" + sdk_log_file)
            with open(__location__ + "/log.txt", "a+") as logfile:
                # print('sdk_log_file function')
                logfile.write(post_data.decode('utf-8') + ",")
                logfile.close()
        except IOError:
            pass
def main():
    try:
        # Create a web server and define the handler to manage the incoming request
        server = HTTPServer(('', 8080), HttpHandler)
        print('Started httpserver on port ', 8080)
        # Wait forever for incoming http requests
        server.serve_forever()
    #Press Ctrl + C to quit
    except KeyboardInterrupt:
        print('^C received, shutting down the web server')
        server.socket.close()
if __name__ == "__main__":
    main()