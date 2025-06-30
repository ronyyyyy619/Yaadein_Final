import { logger } from '../utils/logger';

// Mock queue implementation that doesn't require Redis
class MockQueue {
  name: string;
  
  constructor(name: string) {
    this.name = name;
    logger.info(`Created mock queue: ${name}`);
  }
  
  async add(jobName: string, data: any, options?: any) {
    logger.info(`Job ${jobName} added to mock queue ${this.name}`, { data, options });
    return { id: `mock-${Date.now()}`, data, options };
  }
  
  on(event: string, callback: Function) {
    // No-op for mock queue
    return this;
  }
  
  async getWaitingCount() { return 0; }
  async getActiveCount() { return 0; }
  async getCompletedCount() { return 0; }
  async getFailedCount() { return 0; }
}

// Create mock queues
export const imageAnalysisQueue = new MockQueue('image-analysis');
export const faceRecognitionQueue = new MockQueue('face-recognition');
export const tagGenerationQueue = new MockQueue('tag-generation');

// Log queue status on startup
const logQueueStatus = async () => {
  try {
    logger.info('Using mock queues - Redis not available');
  } catch (error) {
    logger.error('Error logging queue status:', error);
  }
};

logQueueStatus();

// Export all queues
export const queues = {
  imageAnalysisQueue,
  faceRecognitionQueue,
  tagGenerationQueue
};