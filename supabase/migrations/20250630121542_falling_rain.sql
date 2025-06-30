/*
  # Create storage buckets for memory media

  1. Storage Buckets
    - `memory_media` - for storing photos, videos, audio files
  2. Security
    - Enable RLS on storage buckets
    - Add policies for family members to upload and access media
*/

-- Create storage bucket for memory media
INSERT INTO storage.buckets (id, name, public)
VALUES ('memory_media', 'memory_media', true)
ON CONFLICT (id) DO NOTHING;

-- Policy for authenticated users to upload files
CREATE POLICY "Authenticated users can upload memory media"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'memory_media' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Policy for authenticated users to view files
CREATE POLICY "Authenticated users can view memory media"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (bucket_id = 'memory_media');

-- Policy for file owners to update their files
CREATE POLICY "Users can update their own memory media"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (bucket_id = 'memory_media' AND auth.uid()::text = (storage.foldername(name))[1])
  WITH CHECK (bucket_id = 'memory_media' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Policy for file owners to delete their files
CREATE POLICY "Users can delete their own memory media"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (bucket_id = 'memory_media' AND auth.uid()::text = (storage.foldername(name))[1]);