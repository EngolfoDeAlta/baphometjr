import time
import pyautogui
import requests
from datetime import datetime

# CONFIGURAÇÕES
CHECK_INTERVAL = 60  # 1 minuto
SCREENSHOT_INTERVAL = 600  # 10 minutos
TELEGRAM_TOKEN = "X"
TELEGRAM_CHAT_ID = "8142591277"

# CAMINHOS DAS IMAGENS DE REFERÊNCIA
IMAGENS_ESTADO = {
    "Desconectado": "dc.png",
    "Morto": "morto.png",
    "Com peso alto": "peso.png"
}

def enviar_mensagem(texto):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Enviando mensagem para Telegram: {texto}")
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
    data = {
        "chat_id": TELEGRAM_CHAT_ID,
        "text": texto
    }
    response = requests.post(url, data=data)
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Resposta da API (mensagem): {response.status_code}")

def enviar_screenshot():
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Tirando screenshot...")
    screenshot = pyautogui.screenshot()
    caminho = "screenshot.png"
    screenshot.save(caminho)

    print(f"[{datetime.now().strftime('%H:%M:%S')}] Enviando screenshot para Telegram...")
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendPhoto"
    with open(caminho, 'rb') as f:
        files = {"photo": f}
        data = {"chat_id": TELEGRAM_CHAT_ID}
        response = requests.post(url, files=files, data=data)
        print(f"[{datetime.now().strftime('%H:%M:%S')}] Resposta da API (foto): {response.status_code}")

def checar_estado():
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Verificando estado na tela...")
    for estado, imagem in IMAGENS_ESTADO.items():
        print(f"Procurando por: {estado} (imagem: {imagem})")

        # Define confidence conforme o estado
        if estado == "Com peso alto":
            conf = 0.6
        else:
            conf = 0.8

        try:
            localizacao = pyautogui.locateOnScreen(imagem, confidence=conf)
            if localizacao:
                print(f"Estado detectado: {estado} com confidence={conf}")
                return estado
        except pyautogui.ImageNotFoundException:
            print(f"Imagem '{imagem}' não encontrada na tela (não é um erro, continua o loop).")
    print("Nenhum estado crítico detectado.")
    return None

# LOOP PRINCIPAL
print("Iniciando monitoramento...")
ultimo_screenshot = time.time()

while True:
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Iniciando verificação...")
    estado = checar_estado()

    if estado:
        enviar_mensagem(f"[{datetime.now().strftime('%H:%M:%S')}] Alerta: {estado}")
        print(f"Aguardando 10 segundos após alerta de '{estado}'...")
        time.sleep(10)

    if time.time() - ultimo_screenshot >= SCREENSHOT_INTERVAL:
        enviar_mensagem(f"[{datetime.now().strftime('%H:%M:%S')}] Print periódico")
        enviar_screenshot()
        ultimo_screenshot = time.time()

    print(f"[{datetime.now().strftime('%H:%M:%S')}] Aguardando {CHECK_INTERVAL} segundos até próxima verificação...\n")
    time.sleep(CHECK_INTERVAL)
