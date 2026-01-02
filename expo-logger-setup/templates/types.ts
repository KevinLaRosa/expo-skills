export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
  NONE = 4,
}

export type LogCategory =
  | 'api'
  | 'websocket'
  | 'auth'
  | 'storage'
  | 'navigation'
  | 'ui'
  | 'revenuecat'
  | 'webhook'
  | 'init'
  | 'error'
  | 'success'
  | 'warning'
  | 'info'
  | 'notification'
  | 'background'
  | 'deeplink';

export interface CategoryMeta {
  emoji: string;
  name: string;
  color?: string; // ANSI color code for terminal
}

export const CATEGORIES: Record<LogCategory, CategoryMeta> = {
  api: { emoji: '📡', name: 'API', color: '\x1b[36m' },           // Cyan
  websocket: { emoji: '🔌', name: 'WebSocket', color: '\x1b[35m' }, // Magenta
  auth: { emoji: '🔐', name: 'Auth', color: '\x1b[33m' },         // Yellow
  storage: { emoji: '💾', name: 'Storage', color: '\x1b[34m' },   // Blue
  navigation: { emoji: '🧭', name: 'Navigation', color: '\x1b[32m' }, // Green
  ui: { emoji: '🎨', name: 'UI', color: '\x1b[37m' },             // White
  revenuecat: { emoji: '💳', name: 'RevenueCat', color: '\x1b[33m' }, // Yellow
  webhook: { emoji: '📨', name: 'Webhook', color: '\x1b[35m' },   // Magenta
  init: { emoji: '🚀', name: 'Init', color: '\x1b[32m' },         // Green
  error: { emoji: '❌', name: 'Error', color: '\x1b[31m' },       // Red
  success: { emoji: '✅', name: 'Success', color: '\x1b[32m' },   // Green
  warning: { emoji: '⚠️', name: 'Warning', color: '\x1b[33m' },   // Yellow
  info: { emoji: 'ℹ️', name: 'Info', color: '\x1b[37m' },         // White
  notification: { emoji: '🔔', name: 'Notification', color: '\x1b[35m' }, // Magenta
  background: { emoji: '⏰', name: 'Background', color: '\x1b[34m' },     // Blue
  deeplink: { emoji: '🔗', name: 'DeepLink', color: '\x1b[36m' },        // Cyan
};

export interface LogEntry {
  timestamp: string;
  category: LogCategory;
  level: LogLevel;
  message: string;
  data?: any;
  error?: {
    name: string;
    message: string;
    stack?: string;
  };
  context?: {
    screen?: string;
    component?: string;
    botId?: string;
    userId?: string;
  };
}

export interface LoggerConfig {
  minLevel: LogLevel;
  enableConsole: boolean;
  enableTimestamps: boolean;
  enableColors: boolean;
  context?: Record<string, any>;
}

export interface Transport {
  write(entry: LogEntry): void;
}
