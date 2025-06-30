import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

interface OfflineData {
  id: string;
  type: 'memory' | 'family_member';
  data: any;
  timestamp: number;
  retryCount?: number;
}

export function useOfflineSync() {
  const [isOnline, setIsOnline] = useState(navigator.onLine);
  const [pendingSync, setPendingSync] = useState<OfflineData[]>([]);
  const [isSyncing, setIsSyncing] = useState(false);

  useEffect(() => {
    const handleOnline = () => {
      setIsOnline(true);
      syncPendingData();
    };

    const handleOffline = () => {
      setIsOnline(false);
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    // Load pending data from localStorage
    loadPendingData();

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  const loadPendingData = () => {
    try {
      const stored = localStorage.getItem('memorymesh_pending_sync');
      if (stored) {
        setPendingSync(JSON.parse(stored));
      }
    } catch (error) {
      console.error('Error loading pending sync data:', error);
    }
  };

  const savePendingData = (data: OfflineData[]) => {
    try {
      localStorage.setItem('memorymesh_pending_sync', JSON.stringify(data));
      setPendingSync(data);
    } catch (error) {
      console.error('Error saving pending sync data:', error);
    }
  };

  const addToSyncQueue = (type: 'memory' | 'family_member', data: any) => {
    const newItem: OfflineData = {
      id: crypto.randomUUID(),
      type,
      data,
      timestamp: Date.now(),
      retryCount: 0
    };

    const updated = [...pendingSync, newItem];
    savePendingData(updated);

    if (isOnline) {
      syncPendingData();
    }
  };

  const syncPendingData = async () => {
    if (!isOnline || pendingSync.length === 0 || isSyncing) return;

    setIsSyncing(true);
    const successful: string[] = [];
    const failed: string[] = [];
    const updatedItems: OfflineData[] = [...pendingSync];

    for (const item of pendingSync) {
      try {
        if (supabase) {
          if (item.type === 'memory') {
            // Upload memory to Supabase
            const { file, title, description, date, user_id, family_id } = item.data;
            
            if (file) {
              // First upload the file to storage
              const fileExt = file.name.split('.').pop();
              const fileName = `${user_id}/${Date.now()}.${fileExt}`;
              const filePath = `memories/${fileName}`;
              
              const { error: uploadError } = await supabase.storage
                .from('memory_media')
                .upload(filePath, file);
                
              if (uploadError) {
                console.error('Error uploading file:', uploadError);
                
                // Increment retry count
                const itemIndex = updatedItems.findIndex(i => i.id === item.id);
                if (itemIndex !== -1) {
                  updatedItems[itemIndex].retryCount = (updatedItems[itemIndex].retryCount || 0) + 1;
                  
                  // If we've tried too many times, mark as failed
                  if (updatedItems[itemIndex].retryCount! >= 3) {
                    failed.push(item.id);
                  }
                }
                
                continue;
              }
              
              // Get public URL
              const { data: urlData } = supabase.storage
                .from('memory_media')
                .getPublicUrl(filePath);
                
              const fileUrl = urlData.publicUrl;
              
              // Create memory record
              const { error: memoryError } = await supabase
                .from('memories')
                .insert([
                  {
                    family_id: family_id,
                    title,
                    description,
                    memory_type: file.type.startsWith('image/') ? 'photo' : 
                                file.type.startsWith('video/') ? 'video' : 
                                file.type.startsWith('audio/') ? 'audio' : 'story',
                    file_url: fileUrl,
                    thumbnail_url: file.type.startsWith('image/') ? fileUrl : null,
                    date_taken: date,
                    created_by: user_id,
                    is_private: false
                  }
                ]);
                
              if (memoryError) {
                console.error('Error creating memory record:', memoryError);
                
                // Increment retry count
                const itemIndex = updatedItems.findIndex(i => i.id === item.id);
                if (itemIndex !== -1) {
                  updatedItems[itemIndex].retryCount = (updatedItems[itemIndex].retryCount || 0) + 1;
                  
                  // If we've tried too many times, mark as failed
                  if (updatedItems[itemIndex].retryCount! >= 3) {
                    failed.push(item.id);
                  }
                }
                
                continue;
              }
              
              successful.push(item.id);
            } else if (item.data.type === 'story') {
              // Handle story type memory (no file upload)
              const { error: memoryError } = await supabase
                .from('memories')
                .insert([
                  {
                    family_id: family_id || item.data.family_id,
                    title: item.data.title,
                    description: item.data.content,
                    memory_type: 'story',
                    date_taken: item.data.date,
                    created_by: user_id,
                    is_private: false
                  }
                ]);
                
              if (memoryError) {
                console.error('Error creating story memory:', memoryError);
                
                // Increment retry count
                const itemIndex = updatedItems.findIndex(i => i.id === item.id);
                if (itemIndex !== -1) {
                  updatedItems[itemIndex].retryCount = (updatedItems[itemIndex].retryCount || 0) + 1;
                  
                  // If we've tried too many times, mark as failed
                  if (updatedItems[itemIndex].retryCount! >= 3) {
                    failed.push(item.id);
                  }
                }
                
                continue;
              }
              
              successful.push(item.id);
            }
          } else if (item.type === 'family_member') {
            await supabase.from('family_members').insert(item.data);
            successful.push(item.id);
          }
        } else {
          // In a real app with Supabase, you would sync the data here
          console.log(`Syncing ${item.type}:`, item.data);
          
          // Simulate successful sync
          await new Promise(resolve => setTimeout(resolve, 500));
          successful.push(item.id);
        }
      } catch (error) {
        console.error(`Failed to sync ${item.type}:`, error);
        
        // Increment retry count
        const itemIndex = updatedItems.findIndex(i => i.id === item.id);
        if (itemIndex !== -1) {
          updatedItems[itemIndex].retryCount = (updatedItems[itemIndex].retryCount || 0) + 1;
          
          // If we've tried too many times, mark as failed
          if (updatedItems[itemIndex].retryCount! >= 3) {
            failed.push(item.id);
          }
        }
      }
    }

    // Handle conflict resolution for items that failed due to conflicts
    // In a real app, you would implement a more sophisticated conflict resolution strategy
    // For now, we'll just remove items that were successfully synced or failed too many times
    const remaining = updatedItems.filter(item => 
      !successful.includes(item.id) && !failed.includes(item.id)
    );
    
    savePendingData(remaining);
    setIsSyncing(false);
  };

  return {
    isOnline,
    isSyncing,
    pendingSync: pendingSync.length,
    addToSyncQueue,
    syncPendingData
  };
}