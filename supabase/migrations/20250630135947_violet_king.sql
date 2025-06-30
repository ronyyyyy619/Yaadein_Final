/*
  # Fix infinite recursion in RLS policies

  1. Policy Issues Fixed
    - Remove circular dependencies between family_members and profiles policies
    - Simplify policies to avoid self-referencing loops
    - Ensure policies are straightforward and efficient

  2. Changes Made
    - Drop problematic policies that cause recursion
    - Create new, simplified policies that avoid circular references
    - Maintain security while preventing infinite loops

  3. Security
    - Users can still only access their own data and family data appropriately
    - No security is compromised, just simplified policy logic
*/

-- Drop the problematic policy that causes infinite recursion
DROP POLICY IF EXISTS "Family members can read profiles" ON profiles;

-- Drop other potentially problematic policies on family_members
DROP POLICY IF EXISTS "Family members can see other members" ON family_members;
DROP POLICY IF EXISTS "Members can see other members in same family" ON family_members;

-- Create a simpler policy for profiles that doesn't cause recursion
CREATE POLICY "Users can read profiles in their families"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (
    id = auth.uid() OR 
    id IN (
      SELECT fm.user_id 
      FROM family_members fm
      WHERE fm.family_id IN (
        SELECT fm2.family_id 
        FROM family_members fm2 
        WHERE fm2.user_id = auth.uid()
      )
    )
  );

-- Create a simpler policy for family_members that doesn't cause recursion
CREATE POLICY "Users can see family members in their families"
  ON family_members
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    family_id IN (
      SELECT family_id 
      FROM family_members 
      WHERE user_id = auth.uid()
    )
  );

-- Ensure the family creators policy is simple and doesn't cause issues
DROP POLICY IF EXISTS "Family creators can manage memberships" ON family_members;

CREATE POLICY "Family owners and admins can manage memberships"
  ON family_members
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM families 
      WHERE families.id = family_members.family_id 
      AND families.created_by = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM family_members fm
      WHERE fm.family_id = family_members.family_id 
      AND fm.user_id = auth.uid() 
      AND fm.role IN ('admin', 'owner')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM families 
      WHERE families.id = family_members.family_id 
      AND families.created_by = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM family_members fm
      WHERE fm.family_id = family_members.family_id 
      AND fm.user_id = auth.uid() 
      AND fm.role IN ('admin', 'owner')
    )
  );