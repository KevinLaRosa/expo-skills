/// <reference path="../../types/global.d.ts" />
import { LogLevel, LogCategory, LogEntry, LoggerConfig, Transport } from './types';
import { formatConsoleMessage } from './formatters';

class Logger {
  private config: LoggerConfig;
  private transports: Transport[] = [];
  private static instance: Logger;

  private constructor(config: Partial<LoggerConfig> = {}) {
    this.config = {
      minLevel: __DEV__ ? LogLevel.DEBUG : LogLevel.NONE,
      enableConsole: true,
      enableTimestamps: true,
      enableColors: true,
      ...config,
    };
  }

  static getInstance(config?: Partial<LoggerConfig>): Logger {
    if (!Logger.instance) {
      Logger.instance = new Logger(config);
    }
    return Logger.instance;
  }

  /**
   * Main logging method
   */
  private log(
    category: LogCategory,
    level: LogLevel,
    message: string,
    data?: any,
    error?: Error
  ): void {
    // Early return in production for performance (zero overhead)
    if (!__DEV__ && level < this.config.minLevel) {
      return;
    }

    // Also respect minLevel in development
    if (level < this.config.minLevel) {
      return;
    }

    const entry: LogEntry = {
      timestamp: new Date().toISOString(),
      category,
      level,
      message,
      data,
      error: error
        ? {
            name: error.name,
            message: error.message,
            stack: error.stack,
          }
        : undefined,
    };

    // Console output (colored, formatted)
    if (this.config.enableConsole) {
      this.writeToConsole(entry);
    }

    // Custom transports
    this.transports.forEach((transport) => transport.write(entry));
  }

  private writeToConsole(entry: LogEntry): void {
    const formatted = formatConsoleMessage(entry, this.config);

    switch (entry.level) {
      case LogLevel.ERROR:
        console.error(formatted);
        if (entry.error?.stack) {
          console.error(entry.error.stack);
        }
        break;
      case LogLevel.WARN:
        console.warn(formatted);
        break;
      default:
        console.log(formatted);
    }
  }

  /**
   * Category-specific loggers (fluent API)
   */
  get api() {
    return this.createCategoryLogger('api');
  }

  get websocket() {
    return this.createCategoryLogger('websocket');
  }

  get auth() {
    return this.createCategoryLogger('auth');
  }

  get storage() {
    return this.createCategoryLogger('storage');
  }

  get navigation() {
    return this.createCategoryLogger('navigation');
  }

  get ui() {
    return this.createCategoryLogger('ui');
  }

  get revenuecat() {
    return this.createCategoryLogger('revenuecat');
  }

  get webhook() {
    return this.createCategoryLogger('webhook');
  }

  get init() {
    return this.createCategoryLogger('init');
  }

  get notification() {
    return this.createCategoryLogger('notification');
  }

  get background() {
    return this.createCategoryLogger('background');
  }

  get deeplink() {
    return this.createCategoryLogger('deeplink');
  }

  private createCategoryLogger(category: LogCategory) {
    return {
      debug: (message: string, data?: any) => this.log(category, LogLevel.DEBUG, message, data),
      info: (message: string, data?: any) => this.log(category, LogLevel.INFO, message, data),
      warn: (message: string, data?: any) => this.log(category, LogLevel.WARN, message, data),
      error: (message: string, errorOrData?: Error | any, data?: any) => {
        const isError = errorOrData instanceof Error;
        this.log(
          category,
          LogLevel.ERROR,
          message,
          isError ? data : errorOrData,
          isError ? errorOrData : undefined
        );
      },
      success: (message: string, data?: any) => this.log(category, LogLevel.INFO, message, data),
    };
  }

  /**
   * Direct level methods (no category - uses 'info' category)
   */
  debug(message: string, data?: any): void {
    this.log('info', LogLevel.DEBUG, message, data);
  }

  info(message: string, data?: any): void {
    this.log('info', LogLevel.INFO, message, data);
  }

  warn(message: string, data?: any): void {
    this.log('warning', LogLevel.WARN, message, data);
  }

  error(message: string, errorOrData?: Error | any, data?: any): void {
    const isError = errorOrData instanceof Error;
    this.log('error', LogLevel.ERROR, message, isError ? data : errorOrData, isError ? errorOrData : undefined);
  }

  /**
   * Success helper (common pattern in codebase)
   */
  success(message: string, data?: any): void {
    this.log('success', LogLevel.INFO, message, data);
  }

  /**
   * Configuration methods
   */
  setMinLevel(level: LogLevel): void {
    this.config.minLevel = level;
  }

  addTransport(transport: Transport): void {
    this.transports.push(transport);
  }

  removeTransport(transport: Transport): void {
    this.transports = this.transports.filter((t) => t !== transport);
  }

  /**
   * Get current configuration
   */
  getConfig(): LoggerConfig {
    return { ...this.config };
  }
}

// Export singleton instance
export const logger = Logger.getInstance();
