/*
  # Fix RLS Policy Infinite Recursion

  1. Problem
    - Circular dependency between family_members and families table policies
    - family_members policies reference families table
    - families policies reference family_members table
    - This creates infinite recursion

  2. Solution
    - Simplify family_members policies to avoid circular references
    - Remove problematic policies that cause recursion
    - Keep essential policies for security while breaking the loop

  3. Changes
    - Remove "Family admins can read memberships via families" policy
    - Remove "Family creators can manage all memberships" policy  
    - Remove "Family owners can manage all memberships" policy
    - Keep simple, direct policies that don't create circular references
*/

-- Drop problematic policies that cause recursion
DROP POLICY IF EXISTS "Family admins can read memberships via families" ON family_members;
DROP POLICY IF EXISTS "Family creators can manage all memberships" ON family_members;
DROP POLICY IF EXISTS "Family owners can manage all memberships" ON family_members;

-- Keep the essential policies that work without recursion
-- These policies are already present and don't cause recursion:
-- 1. "Users can read own family memberships" - allows users to see their own memberships
-- 2. "Users can insert own family memberships" - allows users to join families
-- 3. "Users can update own family memberships" - allows users to update their own membership
-- 4. "Family admins can delete other user memberships" - allows admins to remove members
-- 5. "Family admins can manage other user memberships" - allows admins to update other memberships

-- Add a simplified policy for family creators to manage memberships without recursion
CREATE POLICY "Family creators can manage memberships directly"
  ON family_members
  FOR ALL
  TO authenticated
  USING (
    -- Check if the current user created the family by looking at families table
    -- But use a direct join instead of EXISTS to avoid recursion
    family_id IN (
      SELECT id FROM families WHERE created_by = auth.uid()
    )
  )
  WITH CHECK (
    family_id IN (
      SELECT id FROM families WHERE created_by = auth.uid()
    )
  );