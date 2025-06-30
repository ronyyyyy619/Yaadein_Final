/*
  # Create memory_tags junction table

  1. New Tables
    - `memory_tags`
      - `id` (uuid, primary key)
      - `memory_id` (uuid, foreign key to memories)
      - `tag_id` (uuid, foreign key to tags)
      - `created_at` (timestamp)
  2. Security
    - Enable RLS on `memory_tags` table
    - Add policy for family members to read memory tags
    - Add policy for family members to create memory tags
  3. Indexes
    - Add index on memory_id for faster queries
    - Add index on tag_id for faster queries
    - Add unique constraint on memory_id + tag_id
*/

CREATE TABLE IF NOT EXISTS memory_tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  memory_id uuid REFERENCES memories(id) ON DELETE CASCADE NOT NULL,
  tag_id uuid REFERENCES tags(id) ON DELETE CASCADE NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(memory_id, tag_id)
);

ALTER TABLE memory_tags ENABLE ROW LEVEL SECURITY;

-- Policy for family members to read memory tags
CREATE POLICY "Family members can read memory tags"
  ON memory_tags
  FOR SELECT
  TO authenticated
  USING (
    memory_id IN (
      SELECT m.id 
      FROM memories m
      JOIN family_members fm ON m.family_id = fm.family_id
      WHERE fm.user_id = auth.uid()
    )
  );

-- Policy for family members to create memory tags
CREATE POLICY "Family members can create memory tags"
  ON memory_tags
  FOR INSERT
  TO authenticated
  WITH CHECK (
    memory_id IN (
      SELECT m.id 
      FROM memories m
      JOIN family_members fm ON m.family_id = fm.family_id
      WHERE fm.user_id = auth.uid()
    )
  );

-- Policy for memory creators and family admins to delete memory tags
CREATE POLICY "Memory creators and family admins can delete memory tags"
  ON memory_tags
  FOR DELETE
  TO authenticated
  USING (
    memory_id IN (
      SELECT m.id 
      FROM memories m
      JOIN family_members fm ON m.family_id = fm.family_id
      WHERE fm.user_id = auth.uid() AND (
        m.created_by = auth.uid() OR fm.role = 'admin'
      )
    )
  );

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS memory_tags_memory_id_idx ON memory_tags(memory_id);
CREATE INDEX IF NOT EXISTS memory_tags_tag_id_idx ON memory_tags(tag_id);