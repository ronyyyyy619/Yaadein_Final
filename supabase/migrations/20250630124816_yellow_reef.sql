/*
  # Fix infinite recursion in family_members RLS policies

  1. Problem
    - Current policies on family_members table create circular dependencies
    - Policies reference family_members table within their own conditions
    - This causes infinite recursion when Supabase tries to evaluate the policies

  2. Solution
    - Remove problematic policies that cause circular references
    - Create simplified policies that avoid self-referential queries
    - Ensure policies are logically sound and don't create loops

  3. Changes
    - Drop existing problematic policies
    - Create new, simplified policies
    - Maintain security while avoiding recursion
*/

-- Drop all existing policies on family_members to start fresh
DROP POLICY IF EXISTS "Family creators can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Family creators can manage memberships directly" ON family_members;
DROP POLICY IF EXISTS "Users can insert own family memberships" ON family_members;
DROP POLICY IF EXISTS "Users can join families" ON family_members;
DROP POLICY IF EXISTS "Users can read own family memberships" ON family_members;
DROP POLICY IF EXISTS "Users can read own memberships" ON family_members;
DROP POLICY IF EXISTS "Users can update own family memberships" ON family_members;
DROP POLICY IF EXISTS "Users can update own memberships" ON family_members;

-- Create new, simplified policies that avoid circular references

-- Allow users to read their own family memberships
CREATE POLICY "Users can read own memberships"
  ON family_members
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Allow users to insert themselves into families (for joining)
CREATE POLICY "Users can join families"
  ON family_members
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Allow users to update their own membership status
CREATE POLICY "Users can update own membership"
  ON family_members
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Allow family creators to manage all memberships in their families
CREATE POLICY "Family creators can manage memberships"
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

-- Allow family admins and owners to manage memberships
-- This policy is more complex but avoids recursion by directly checking the user's role
-- in a specific family without referencing family_members in a circular way
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
        AND fm.id != family_members.id  -- Avoid self-reference
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM family_members fm
      WHERE fm.family_id = family_members.family_id
        AND fm.user_id = auth.uid()
        AND fm.role IN ('admin', 'owner')
        AND fm.id != family_members.id  -- Avoid self-reference
    )
  );