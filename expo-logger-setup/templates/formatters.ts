import { LogEntry, LogLevel, CATEGORIES, LoggerConfig } from './types';

const RESET = '\x1b[0m';
const LEVEL_COLORS = {
  [LogLevel.DEBUG]: '\x1b[90m',  // Gray
  [LogLevel.INFO]: '\x1b[37m',   // White
  [LogLevel.WARN]: '\x1b[33m',   // Yellow
  [LogLevel.ERROR]: '\x1b[31m',  // Red
  [LogLevel.NONE]: '\x1b[37m',   // White
};

/**
 * Format log entry for console output (colored, emoji, readable)
 */
export function formatConsoleMessage(entry: LogEntry, config: LoggerConfig): string {
  const { emoji, color } = CATEGORIES[entry.category];
  const timestamp = config.enableTimestamps
    ? `[${new Date(entry.timestamp).toLocaleTimeString()}]`
    : '';

  const categoryLabel = config.enableColors
    ? `${color}${emoji} ${CATEGORIES[entry.category].name}${RESET}`
    : `${emoji} ${CATEGORIES[entry.category].name}`;

  const levelColor = LEVEL_COLORS[entry.level];
  const levelLabel = LogLevel[entry.level];

  const parts = [
    timestamp,
    categoryLabel,
    config.enableColors ? `${levelColor}${entry.message}${RESET}` : entry.message,
  ].filter(Boolean);

  // Add structured data if present
  if (entry.data !== undefined) {
    if (typeof entry.data === 'object' && entry.data !== null) {
      try {
        // Pretty print for console
        const dataStr = JSON.stringify(entry.data, null, 2);
        parts.push(`\n${dataStr}`);
      } catch (e) {
        // Fallback for circular references
        parts.push(String(entry.data));
      }
    } else {
      parts.push(String(entry.data));
    }
  }

  return parts.join(' ');
}

/**
 * Format log entry for file output (grep-friendly, structured)
 */
export function formatFileMessage(entry: LogEntry): string {
  const { emoji, name } = CATEGORIES[entry.category];
  const level = LogLevel[entry.level].padEnd(5);
  const timestamp = entry.timestamp;

  let line = `${timestamp} [${level}] ${emoji} ${name}: ${entry.message}`;

  if (entry.data !== undefined) {
    try {
      line += ` | data=${JSON.stringify(entry.data)}`;
    } catch (e) {
      line += ` | data=[Circular]`;
    }
  }

  if (entry.error) {
    line += ` | error=${entry.error.message}`;
  }

  return line;
}

/**
 * Format log entry as JSON (for structured logging tools)
 */
export function formatJSONMessage(entry: LogEntry): string {
  return JSON.stringify(entry);
}

/**
 * Format error with stack trace
 */
export function formatError(error: Error): string {
  return `${error.name}: ${error.message}\n${error.stack || ''}`;
}
