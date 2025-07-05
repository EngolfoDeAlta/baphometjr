from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse
import interception

interception.auto_capture_devices()

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        query = urllib.parse.parse_qs(parsed.query)

        if parsed.path == "/move_and_click":
            try:
                x = int(query.get("x", [0])[0])
                y = int(query.get("y", [0])[0])
                interception.move_to(x, y)
                interception.click(button="left")
                print(f"Movido para ({x}, {y}) e clicado.")
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"OK")
            except Exception as e:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(f"Erro: {str(e)}".encode())

        elif parsed.path == "/move_only":
            try:
                x = int(query.get("x", [0])[0])
                y = int(query.get("y", [0])[0])
                interception.move_to(x, y)
                print(f"Movido para ({x}, {y}) sem clicar.")
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"OK")
            except Exception as e:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(f"Erro: {str(e)}".encode())

        elif parsed.path == "/click_only":
            try:
                interception.click(button="left")
                print(f"Clique realizado na posição atual do mouse.")
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"OK")
            except Exception as e:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(f"Erro: {str(e)}".encode())

        elif parsed.path == "/press_key":
            try:
                print("Requisição recebida em /press_key")
                key = query.get("key", [""])[0]
                interception.press(key)
                print(f"Tecla pressionada: {key}")
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"OK")
            except Exception as e:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(f"Erro: {str(e)}".encode())

        else:
            self.send_response(404)
            self.end_headers()

HOST = "127.0.0.1"
PORT = 8000
print(f"Servidor Python rodando em http://{HOST}:{PORT}")
server = HTTPServer((HOST, PORT), SimpleHandler)
server.serve_forever()
