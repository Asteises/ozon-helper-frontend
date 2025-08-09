export interface SyncStatusInfo {
    taskId: string;
    catalogStatus: 'SYNCING' | 'READY' | 'FAILED';
    syncStatus: 'RUNNING' | 'READY' | 'FAILED';
    progress: number; // 0..100
    startedAt: string;
}

export interface RequestData {
    telegramUserId: number,
    taskId: string
}