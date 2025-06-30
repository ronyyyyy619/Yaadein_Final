import { createClient } from '@supabase/supabase-js'
import type { Database } from './database.types'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  console.warn('Missing Supabase environment variables. Using mock data instead.')
}

export const supabase = supabaseUrl && supabaseAnonKey 
  ? createClient<Database>(supabaseUrl, supabaseAnonKey, {
      auth: {
        autoRefreshToken: true,
        persistSession: true,
        detectSessionInUrl: true
      },
      realtime: {
        params: {
          eventsPerSecond: 10,
        },
      },
    })
  : null;

// Helper function to get current user
export const getCurrentUser = async () => {
  if (!supabase) {
    console.warn('Supabase client not initialized. Using mock data instead.');
    return null;
  }
  
  const { data: { user } } = await supabase.auth.getUser();
  return user;
}

// Helper function to get user profile
export const getUserProfile = async (userId: string) => {
  if (!supabase) {
    console.warn('Supabase client not initialized. Using mock data instead.');
    return { data: null, error: new Error('Supabase client not initialized') };
  }
  
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .single();
  
  return { data, error };
}

// Helper function to create a family
export const createFamily = async (name: string, description: string, createdBy: string, privacyLevel: string = 'family-only') => {
  if (!supabase) {
    console.warn('Supabase client not initialized. Using mock data instead.');
    return { data: null, error: new Error('Supabase client not initialized') };
  }
  
  const { data, error } = await supabase
    .from('families')
    .insert([
      { name, description, created_by: createdBy, privacy_level: privacyLevel }
    ])
    .select();
  
  return { data, error };
}

// Helper function to add a user to a family
export const addFamilyMember = async (familyId: string, userId: string, role: string = 'member') => {
  if (!supabase) {
    console.warn('Supabase client not initialized. Using mock data instead.');
    return { data: null, error: new Error('Supabase client not initialized') };
  }
  
  const { data, error } = await supabase
    .from('family_members')
    .insert([
      { family_id: familyId, user_id: userId, role }
    ])
    .select();
  
  return { data, error };
}

// Helper function to get user's families
export const getUserFamilies = async (userId: string) => {
  if (!supabase) {
    console.warn('Supabase client not initialized. Using mock data instead.');
    return { data: null, error: new Error('Supabase client not initialized') };
  }
  
  const { data, error } = await supabase
    .from('families')
    .select(`
      *,
      family_members!inner(*)
    `)
    .eq('family_members.user_id', userId);
  
  return { data, error };
}

// Helper function to upload a memory
export const uploadMemory = async (
  familyId: string, 
  title: string, 
  description: string, 
  memoryType: string, 
  file: File | null, 
  createdBy: string,
  dateTaken?: string,
  location?: string,
  isPrivate: boolean = false
) => {
  if (!supabase) {
    console.warn('Supabase client not initialized. Using mock data instead.');
    return { data: null, error: new Error('Supabase client not initialized') };
  }
  
  let fileUrl = null;
  let thumbnailUrl = null;
  
  // Upload file if provided
  if (file) {
    const fileExt = file.name.split('.').pop();
    const fileName = `${createdBy}/${Date.now()}.${fileExt}`;
    const filePath = `memories/${fileName}`;
    
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from('memory_media')
      .upload(filePath, file);
      
    if (uploadError) {
      return { error: uploadError };
    }
    
    // Get public URL
    const { data: urlData } = supabase.storage
      .from('memory_media')
      .getPublicUrl(filePath);
      
    fileUrl = urlData.publicUrl;
    
    // For images and videos, use the same URL as thumbnail
    if (memoryType === 'photo' || memoryType === 'video') {
      thumbnailUrl = fileUrl;
    }
  }
  
  // Create memory record
  const { data, error } = await supabase
    .from('memories')
    .insert([
      {
        family_id: familyId,
        title,
        description,
        memory_type: memoryType,
        file_url: fileUrl,
        thumbnail_url: thumbnailUrl,
        date_taken: dateTaken,
        location,
        created_by: createdBy,
        is_private: isPrivate
      }
    ])
    .select();
    
  return { data, error };
}

// Helper function to get memories for a family
export const getFamilyMemories = async (familyId: string) => {
  if (!supabase) {
    console.warn('Supabase client not initialized. Using mock data instead.');
    return { data: null, error: new Error('Supabase client not initialized') };
  }
  
  const { data, error } = await supabase
    .from('memories')
    .select(`
      *,
      profiles(*)
    `)
    .eq('family_id', familyId)
    .order('created_at', { ascending: false });
    
  return { data, error };
}

// Helper function to update user profile
export const updateUserProfile = async (userId: string, profileData: any) => {
  if (!supabase) {
    console.warn('Supabase client not initialized. Using mock data instead.');
    return { data: null, error: new Error('Supabase client not initialized') };
  }
  
  const { data, error } = await supabase
    .from('profiles')
    .update(profileData)
    .eq('id', userId)
    .select();
  
  return { data, error };
}

// Helper function to save onboarding data
export const saveOnboardingData = async (userId: string, onboardingData: any) => {
  if (!supabase) {
    console.warn('Supabase client not initialized. Using mock data instead.');
    return { success: true, error: null };
  }
  
  try {
    // Update user profile with onboarding data
    const { error: profileError } = await supabase
      .from('profiles')
      .update({
        full_name: onboardingData.profile.name,
        avatar_url: onboardingData.profile.profilePhoto,
        // Add other profile fields as needed
      })
      .eq('id', userId);
    
    if (profileError) throw profileError;
    
    // If family creation was selected
    if (onboardingData.family.action === 'create' && onboardingData.family.familyName) {
      const { error: familyError } = await supabase
        .from('families')
        .insert([
          {
            name: onboardingData.family.familyName,
            description: 'Created during onboarding',
            created_by: userId,
            privacy_level: onboardingData.family.privacyLevel
          }
        ]);
      
      if (familyError) throw familyError;
    }
    
    // If first memory was uploaded
    if (onboardingData.firstMemory?.file) {
      const file = onboardingData.firstMemory.file;
      const fileExt = file.name.split('.').pop();
      const fileName = `${userId}/${Date.now()}.${fileExt}`;
      const filePath = `memories/${fileName}`;
      
      // Upload to storage
      const { error: uploadError } = await supabase.storage
        .from('memory_media')
        .upload(filePath, file);
        
      if (uploadError) throw uploadError;
      
      // Get public URL
      const { data: urlData } = supabase.storage
        .from('memory_media')
        .getPublicUrl(filePath);
        
      const fileUrl = urlData.publicUrl;
      
      // Create memory record - we'll need to get the family ID first
      const { data: families, error: familiesError } = await supabase
        .from('families')
        .select('id')
        .eq('created_by', userId)
        .limit(1);
        
      if (familiesError) throw familiesError;
      
      if (families && families.length > 0) {
        const familyId = families[0].id;
        
        const { error: memoryError } = await supabase
          .from('memories')
          .insert([
            {
              family_id: familyId,
              title: onboardingData.firstMemory.title,
              description: onboardingData.firstMemory.description,
              memory_type: file.type.startsWith('image/') ? 'photo' : 
                          file.type.startsWith('video/') ? 'video' : 
                          file.type.startsWith('audio/') ? 'audio' : 'story',
              file_url: fileUrl,
              thumbnail_url: file.type.startsWith('image/') ? fileUrl : null,
              created_by: userId,
              is_private: false
            }
          ]);
          
        if (memoryError) throw memoryError;
      }
    }
    
    return { success: true, error: null };
  } catch (error) {
    console.error('Error saving onboarding data:', error);
    return { success: false, error };
  }
}