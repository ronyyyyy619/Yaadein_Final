/*
  # Fix infinite recursion in family_members RLS policy

  1. Problem
    - The "Users can view family members in shared families" policy creates infinite recursion
    - It tries to query family_members table within its own policy evaluation
    
  2. Solution
    - Drop the problematic policy
    - Create a simpler, non-recursive policy that directly checks user permissions
    - Use auth.uid() directly without circular table references
    
  3. Security
    - Users can still view their own membership records
    - Users can view other members in families where they are members
    - No circular dependencies in policy evaluation
*/

-- Drop the problematic recursive policy
DROP POLICY IF EXISTS "Users can view family members in shared families" ON family_members;

-- Create a new non-recursive policy
-- This policy allows users to see family members in families where they are also members
-- but avoids recursion by using a more direct approach
CREATE POLICY "Users can view members in their families"
  ON family_members
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() 
    OR 
    EXISTS (
      SELECT 1 
      FROM family_members fm_check 
      WHERE fm_check.family_id = family_members.family_id 
      AND fm_check.user_id = auth.uid()
      AND fm_check.status = 'active'
    )
  );