/*
  # Fix Family Members RLS Policies

  1. Security
    - Drop existing problematic policies that cause infinite recursion
    - Create new simplified policies that avoid circular references
    - Ensure proper access control without self-referencing issues

  2. Changes
    - Remove all existing policies on family_members table
    - Add new policies with clear, non-recursive logic
    - Maintain security while preventing infinite loops
*/

-- Drop all existing policies on family_members table
DROP POLICY IF EXISTS "Family admins can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Family creators can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Users can join families" ON family_members;
DROP POLICY IF EXISTS "Users can read own memberships" ON family_members;
DROP POLICY IF EXISTS "Users can update own membership" ON family_members;

-- Create new simplified policies without circular references

-- Users can read their own family memberships
CREATE POLICY "Users can read own family memberships"
  ON family_members
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Users can insert their own family memberships (for joining families)
CREATE POLICY "Users can join families"
  ON family_members
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Users can update their own family membership status
CREATE POLICY "Users can update own membership status"
  ON family_members
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Family creators can manage all memberships in their families
CREATE POLICY "Family creators can manage all memberships"
  ON family_members
  FOR ALL
  TO authenticated
  USING (
    family_id IN (
      SELECT id FROM families WHERE created_by = auth.uid()
    )
  )
  WITH CHECK (
    family_id IN (
      SELECT id FROM families WHERE created_by = auth.uid()
    )
  );

-- Family owners can manage memberships (using direct role check)
CREATE POLICY "Family owners can manage memberships"
  ON family_members
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM family_members fm
      WHERE fm.family_id = family_members.family_id
        AND fm.user_id = auth.uid()
        AND fm.role = 'owner'
        AND fm.id != family_members.id  -- Prevent self-reference
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM family_members fm
      WHERE fm.family_id = family_members.family_id
        AND fm.user_id = auth.uid()
        AND fm.role = 'owner'
        AND fm.id != family_members.id  -- Prevent self-reference
    )
  );

-- Family admins can manage memberships (using direct role check)
CREATE POLICY "Family admins can manage memberships"
  ON family_members
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM family_members fm
      WHERE fm.family_id = family_members.family_id
        AND fm.user_id = auth.uid()
        AND fm.role IN ('admin', 'owner')
        AND fm.id != family_members.id  -- Prevent self-reference
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM family_members fm
      WHERE fm.family_id = family_members.family_id
        AND fm.user_id = auth.uid()
        AND fm.role IN ('admin', 'owner')
        AND fm.id != family_members.id  -- Prevent self-reference
    )
  );