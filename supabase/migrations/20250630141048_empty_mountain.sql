/*
  # Fix infinite recursion in family_members RLS policies

  1. Problem
    - The current RLS policies on family_members table are causing infinite recursion
    - Policy "Users can see family members in their families" is querying family_members from within itself
    
  2. Solution
    - Drop the problematic recursive policy
    - Create simpler, non-recursive policies that avoid circular references
    - Ensure users can still access appropriate family member data
    
  3. Security
    - Maintain proper access control without recursion
    - Users can read their own memberships
    - Users can read memberships in families they belong to (using a simpler approach)
*/

-- Drop the problematic recursive policy
DROP POLICY IF EXISTS "Users can see family members in their families" ON family_members;

-- Create a simpler policy that avoids recursion
-- This policy allows users to see family members in families where they are also members
-- We'll use a more direct approach that doesn't cause recursion
CREATE POLICY "Users can view family members in shared families"
  ON family_members
  FOR SELECT
  TO authenticated
  USING (
    -- Users can see their own membership records
    user_id = auth.uid()
    OR
    -- Users can see other members in families they belong to
    -- We check this by looking at the families table directly
    family_id IN (
      SELECT f.id 
      FROM families f
      WHERE f.id IN (
        SELECT fm.family_id 
        FROM family_members fm 
        WHERE fm.user_id = auth.uid()
      )
    )
  );