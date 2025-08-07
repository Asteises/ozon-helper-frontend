<template>
  <div v-if="statusInternal === 'IN_PROGRESS'" class="progress-bar">
    <div class="progress-fill" :style="{ width: progress + '%' }"></div>
    <p>Прогресс: {{ progress }}%</p>
  </div>

  <p v-if="statusInternal === 'DONE'" class="success-message">
    ✅ Все товары успешно синхронизированы
  </p>

  <p v-if="statusInternal === 'FAILED'" class="error-message">
    ❌ Ошибка синхронизации. Повторите попытку позднее.
  </p>
</template>

<script setup lang="ts">
import { ref, watch, onUnmounted } from 'vue'

interface Props {
  telegramUserId: number
  telegramInitData: string
  start: boolean
  modelValue: 'PENDING' | 'IN_PROGRESS' | 'DONE' | 'FAILED' | null
}

const props = defineProps<Props>()
const emit = defineEmits(['update:modelValue'])

const progress = ref(0)
const statusInternal = ref<Props['modelValue']>(props.modelValue)

let intervalId: number | null = null

const startPolling = () => {
  const payload = {
    telegramUserId: props.telegramUserId,
    telegramInitData: props.telegramInitData
  }

  intervalId = window.setInterval(async () => {
    try {
      const response = await fetch('/api/product/sync/status', {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });

      if (!response.ok) throw new Error('Ошибка запроса статуса');

      const data = await response.json();
      progress.value = data.progress;
      statusInternal.value = data.status;

      emit('update:modelValue', data.status);

      if (data.status === 'DONE' || data.status === 'FAILED') {
        if (intervalId) clearInterval(intervalId);
      }

    } catch (e) {
      console.error('Ошибка при опросе статуса:', e);
      statusInternal.value = 'FAILED';
      emit('update:modelValue', 'FAILED');
      if (intervalId) clearInterval(intervalId);
    }
  }, 3000)
}

watch(() => props.start, (newVal) => {
  if (newVal) {
    statusInternal.value = 'IN_PROGRESS'
    emit('update:modelValue', 'IN_PROGRESS')
    startPolling()
  }
})

onUnmounted(() => {
  if (intervalId) clearInterval(intervalId);
})
</script>

<style scoped>
.progress-bar {
  width: 100%;
  height: 20px;
  background-color: #ccc;
  border-radius: 5px;
  overflow: hidden;
  margin-top: 15px;
}

.progress-fill {
  height: 100%;
  background-color: #4caf50;
  transition: width 0.3s ease;
}

.success-message {
  color: green;
  margin-top: 15px;
}

.error-message {
  color: red;
  margin-top: 15px;
}
</style>
