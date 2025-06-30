import { createClient } from '@supabase/supabase-js';
import { config } from 'dotenv';
import { logger } from '../utils/logger';

// Ensure environment variables are loaded
config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

// Debug logging to see what's actually loaded
console.log('Environment check:');
console.log('SUPABASE_URL exists:', !!supabaseUrl);
console.log('SUPABASE_SERVICE_KEY exists:', !!supabaseServiceKey);
console.log('NODE_ENV:', process.env.NODE_ENV);

if (!supabaseUrl || !supabaseServiceKey) {
  logger.error('Supabase URL or service key not provided in environment variables', {
    service: 'yaadein-ai-backend',
    supabaseUrl: !!supabaseUrl,
    supabaseServiceKey: !!supabaseServiceKey,
    envKeys: Object.keys(process.env).filter(key => key.includes('SUPABASE'))
  });
  
  // Don't exit immediately in development for debugging
  if (process.env.NODE_ENV === 'production') {
    process.exit(1);
  } else {
    console.warn('Continuing in development mode for debugging...');
  }
}

// Create Supabase client with service key for admin access
export const supabase = createClient(
  supabaseUrl || '', 
  supabaseServiceKey || '', 
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
);

// Create Supabase client with anon key for public access
export const supabasePublic = createClient(
  supabaseUrl || '',
  process.env.SUPABASE_ANON_KEY || ''
);

// Test connection
export const testSupabaseConnection = async () => {
  try {
    if (!supabaseUrl || !supabaseServiceKey) {
      logger.error('Cannot test connection: missing credentials');
      return false;
    }

    const { error } = await supabase.from('users').select('count').limit(1);
    
    if (error) {
      logger.error('Supabase connection test failed:', error);
      return false;
    }
    
    logger.info('Supabase connection test successful');
    return true;
  } catch (error) {
    logger.error('Supabase connection test failed:', error);
    return false;
  }
};

// Initialize Supabase connection
export const initializeSupabase = async () => {
  const isConnected = await testSupabaseConnection();
  if (!isConnected) {
    logger.warn('Could not connect to Supabase. Some features may not work properly.');
  }
  return isConnected;
};