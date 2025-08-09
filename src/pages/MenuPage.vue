<template>
  <div class="container">
    <TopNav/>
    <h1>Добро пожаловать в Ozon Helper</h1>
    <p>Выберите действие в меню:</p>
    <button @click="getData" :disabled="loading">
      {{ loading ? `Загрузка: ${progress}%` : 'Получить все товары' }}
    </button>
  </div>
</template>

<script setup lang="ts">
import TopNav from '@/components/TopNav.vue'
import {ref} from "vue";
import {RequestData, SyncStatusInfo} from "../types/sync-status-info";

const loading = ref(false)
const progress = ref(0);
const status = ref<'SYNCING'|'READY'|'FAILED'>('SYNCING');
let es: EventSource | null = null;

declare global {
  interface Window {
    Telegram: any;
  }
}

const tg = window.Telegram?.WebApp;
const taskId = crypto.randomUUID();
console.log("Generate task id: ", taskId)

console.log("Menu Page Income Telegram WebbApp: ", tg)

async function getData() {
  loading.value = true;

  try {
    const user = tg?.initDataUnsafe?.user;
    if (!user) {
      console.log('No Telegram user');
      loading.value = false;
      return;
    }

    const requestPayload: RequestData = {
         telegramUserId: user.id,
             taskId: taskId
    }

    // 1) Сначала открываем stream
    es = new EventSource(`/api/product/sync/stream?taskId=${taskId}`);

    es.addEventListener('connected', () => {
      console.log("Event Listener connected success")
      // 2) Когда поток открыт — запускаем серверный процесс
      fetch('/api/product/sync/list', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestPayload)
      }).catch(err => console.error('POST /sync/list failed', err));
    });

    es.addEventListener('progress', (evt: MessageEvent) => {
      try {
        const info: SyncStatusInfo = JSON.parse(evt.data);
        console.log("Получен прогресс:", info.progress, "%");
        progress.value = info.progress;
        status.value = info.catalogStatus;
        if (status.value === 'READY' || status.value === 'FAILED') {
          es?.close();
          es = null;
          loading.value = false;
        }
      } catch (e) {
        console.error("Ошибка парсинга события progress", e);
      }
    });

    es.onerror = () => {
      // Браузер сам переподключится. Можно показать «потеряно соединение, восстанавливаем...»
      console.warn('SSE error');
    };
  } catch (e) {
    console.error('getData error', e);
    loading.value = false;
    es?.close();
    es = null;
  }
}

// const startSyncOzonData = async () => {
//   loading.value = true;
//
//   try {
//     console.log("initDataUnsafe: ", tg.initDataUnsafe)
//     if (tg.initDataUnsafe?.user) {
//
//       const user = tg.initDataUnsafe.user;
//       const taskId = crypto.randomUUID();
//       const requestPayload: RequestData = {
//         telegramUserId: user.id,
//         taskId: taskId
//       }
//
//       const streamSyncStatusResponse = await fetch('/api/product/sync/stream', {
//         method: 'GET',
//         headers: {'Content-Type': 'application/json'},
//
//       })
//
//       console.log('Sent request for user: ', user.id)
//
//       const response = await fetch('/api/product/sync/list', {
//         method: 'POST',
//         headers: {'Content-Type': 'application/json'},
//         body: JSON.stringify(requestPayload)
//       });
//
//       if (!response.ok) {
//         console.log('Ошибка при получении списка товаров')
//       } else {
//         console.log('Response 200 text: ', response.text())
//       }
//     }
//   } catch (error) {
//     console.log('Error while get product list: ', error)
//   }
// }
</script>
