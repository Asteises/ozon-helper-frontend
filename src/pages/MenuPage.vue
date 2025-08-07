<template>
  <div class="container">
    <TopNav/>
    <h1>Добро пожаловать в Ozon Helper</h1>
    <p>Выберите действие в меню:</p>
    <button @click="getData" :disabled="loading || syncStatus === 'IN_PROGRESS'">
      {{ loading ? 'Загрузка товаров...' : 'Получить все товары' }}
    </button>
    <SyncProgressBar
        v-model="syncStatus"
        :telegramUserId="telegramUserId"
        :telegramInitData="telegramInitData"
        :start="startPolling"
    />
  </div>
</template>

<script setup lang="ts">
import TopNav from '@/components/TopNav.vue'
import {ref} from "vue";
import {CheckUserData} from "../types/tg-user";
import SyncProgressBar from "@/components/SyncProgressBar.vue";

const loading = ref(false)
const syncStatus = ref<'PENDING' | 'IN_PROGRESS' | 'DONE' | 'FAILED' | null>(null)
const startPolling = ref(false)

declare global {
  interface Window {
    Telegram: any;
  }
}

const tg = window.Telegram?.WebApp;
const telegramUserId = tg?.initDataUnsafe?.user?.id
const telegramInitData = tg?.initData || ''

console.log("Manu Page Income Telegram WebbApp: ", tg)

const getData = async () => {
  loading.value = true;

  try {
    console.log("initDataUnsafe: ", tg.initDataUnsafe)
    if (tg.initDataUnsafe?.user) {

      const user = tg.initDataUnsafe.user;

      const requestPayload: CheckUserData = {
        telegramUserId: user.id,
        telegramInitData: user?.initData
      }

      console.log('Sent request for user: ', user.id)

      const response = await fetch('/api/product/sync/list', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(requestPayload)
      });

      if (!response.ok) {
        console.log('Ошибка при получении списка товаров')
      } else {
        console.log('Response 200 text: ', response.text())
        startPolling.value = true
      }
    }
  } catch (error) {
    console.log('Error while get product list: ', error)
    syncStatus.value = 'FAILED'
  } finally {
    loading.value = false
  }
}
</script>
