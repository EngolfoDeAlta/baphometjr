import keyboard
import requests
import time

# URL base do servidor
BASE_URL = "http://127.0.0.1:8000"

# Controle de estado (se está ativo ou não)
modo_spam_ativo = False

def enviar_enter():
    try:
        url = f"{BASE_URL}/press_key?key=enter"
        resposta = requests.get(url, timeout=1)
        print(f"Enviou Enter. Status: {resposta.status_code}")
    except Exception as e:
        print(f"Erro ao enviar Enter: {e}")

def enviar_click():
    try:
        url = f"{BASE_URL}/click_only"
        resposta = requests.get(url, timeout=1)
        print(f"Enviou clique. Status: {resposta.status_code}")
    except Exception as e:
        print(f"Erro ao enviar clique: {e}")

def toggle_modo_spam():
    global modo_spam_ativo
    modo_spam_ativo = not modo_spam_ativo
    estado = "ATIVADO" if modo_spam_ativo else "DESATIVADO"
    print(f"Modo spam {estado}!")

# Atalho para a tecla P (não precisa de Shift, é só P mesmo)
keyboard.add_hotkey('p', toggle_modo_spam)

print("Script iniciado. Pressione 'P' para alternar o modo spam.")

try:
    while True:
        if modo_spam_ativo:
            enviar_enter()
            enviar_click()
            time.sleep(0.1)  # 100ms
        else:
            time.sleep(0.1)
except KeyboardInterrupt:
    print("\nEncerrando o script.")
