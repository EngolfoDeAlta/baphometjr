import pyautogui
import time
import requests

# Cores alvo em RGB
cores_alvo = [
    (189, 198, 206),  # 0xBDC6CE
    (206, 206, 214),  # 0xCECED6
    (214, 222, 222),  # 0xD6DEDE
    (247, 247, 247)   # 0xF7F7F7
]

def cor_proxima(cor1, cor2, tolerancia=10):
    return all(abs(c1 - c2) <= tolerancia for c1, c2 in zip(cor1, cor2))

def enviar_f3():
    url = "http://127.0.0.1:8000/press_key?key=f3"
    try:
        resposta = requests.get(url)
        print(f"Enviou F3. Resposta HTTP: {resposta.status_code}")
    except Exception as e:
        print(f"Erro ao enviar comando F3: {e}")

def main():
    print("Coloque o mouse no local desejado. Capturando posição em 3 segundos...")
    time.sleep(3)
    x, y = pyautogui.position()
    print(f"Posição capturada: ({x}, {y})")

    while True:
        cor = pyautogui.screenshot().getpixel((x, y))
        print(f"Cor no pixel ({x},{y}): {cor}")

        if any(cor_proxima(cor, c) for c in cores_alvo):
            print("Cor alvo encontrada! Enviando comando F3...")
            enviar_f3()
        else:
            print("Cor não encontrada.")

        time.sleep(0.3)

if __name__ == "__main__":
    main()
