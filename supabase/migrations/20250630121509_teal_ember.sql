/*
  # Create memories table

  1. New Tables
    - `memories`
      - `id` (uuid, primary key)
      - `family_id` (uuid, foreign key to families)
      - `title` (text, required)
      - `description` (text, optional)
      - `memory_type` (text, required)
      - `file_url` (text, optional)
      - `thumbnail_url` (text, optional)
      - `date_taken` (date, optional)
      - `location` (text, optional)
      - `created_by` (uuid, foreign key to auth.users)
      - `is_private` (boolean, default false)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
  2. Security
    - Enable RLS on `memories` table
    - Add policy for family members to read memories
    - Add policy for family members to create memories
    - Add policy for memory creators to update/delete their memories
  3. Indexes
    - Add index on family_id for faster queries
    - Add index on created_by for faster queries
    - Add index on date_taken for timeline queries
    - Add index on memory_type for filtering
*/

CREATE TABLE IF NOT EXISTS memories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id uuid REFERENCES families(id) ON DELETE CASCADE NOT NULL,
  title text NOT NULL,
  description text,
  memory_type text NOT NULL CHECK (memory_type IN ('photo', 'video', 'audio', 'story')),
  file_url text,
  thumbnail_url text,
  date_taken date,
  location text,
  created_by uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  is_private boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE memories ENABLE ROW LEVEL SECURITY;

-- Policy for family members to read memories (excluding private ones not created by them)
CREATE POLICY "Family members can read family memories"
  ON memories
  FOR SELECT
  TO authenticated
  USING (
    family_id IN (
      SELECT family_id 
      FROM family_members 
      WHERE user_id = auth.uid()
    ) AND (
      is_private = false OR created_by = auth.uid()
    )
  );

-- Policy for family members to create memories
CREATE POLICY "Family members can create memories"
  ON memories
  FOR INSERT
  TO authenticated
  WITH CHECK (
    family_id IN (
      SELECT family_id 
      FROM family_members 
      WHERE user_id = auth.uid()
    ) AND created_by = auth.uid()
  );

-- Policy for memory creators to update their memories
CREATE POLICY "Memory creators can update their memories"
  ON memories
  FOR UPDATE
  TO authenticated
  USING (created_by = auth.uid())
  WITH CHECK (created_by = auth.uid());

-- Policy for memory creators and family admins to delete memories
CREATE POLICY "Memory creators and family admins can delete memories"
  ON memories
  FOR DELETE
  TO authenticated
  USING (
    created_by = auth.uid() OR
    family_id IN (
      SELECT family_id 
      FROM family_members 
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS memories_family_id_idx ON memories(family_id);
CREATE INDEX IF NOT EXISTS memories_created_by_idx ON memories(created_by);
CREATE INDEX IF NOT EXISTS memories_date_taken_idx ON memories(date_taken);
CREATE INDEX IF NOT EXISTS memories_memory_type_idx ON memories(memory_type);
CREATE INDEX IF NOT EXISTS memories_created_at_idx ON memories(created_at);

-- Create updated_at trigger
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'update_memories_updated_at'
  ) THEN
    CREATE TRIGGER update_memories_updated_at
      BEFORE UPDATE ON memories
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;