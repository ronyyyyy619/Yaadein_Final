-- Drop all problematic policies that cause recursion
DROP POLICY IF EXISTS "Family members can read families" ON families;
DROP POLICY IF EXISTS "Family admins can read memberships via families" ON family_members;
DROP POLICY IF EXISTS "Family creators can manage all memberships" ON family_members;
DROP POLICY IF EXISTS "Family owners can manage all memberships" ON family_members;
DROP POLICY IF EXISTS "Family admins can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Family members can read memberships" ON family_members;
DROP POLICY IF EXISTS "Family admins can read all memberships" ON family_members;
DROP POLICY IF EXISTS "Family admins can manage other memberships" ON family_members;
DROP POLICY IF EXISTS "Family owners can manage all memberships" ON family_members;
DROP POLICY IF EXISTS "Family admins can manage other user memberships" ON family_members;
DROP POLICY IF EXISTS "Family admins can delete other user memberships" ON family_members;

-- Create simplified policies that avoid recursion

-- 1. Users can always read their own family memberships
CREATE POLICY "Users can read own memberships"
  ON family_members
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- 2. Users can insert their own family memberships (for joining families)
CREATE POLICY "Users can join families"
  ON family_members
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- 3. Users can update their own family memberships
CREATE POLICY "Users can update own memberships"
  ON family_members
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- 4. Family creators can manage all memberships in their families
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

-- 5. Create a direct policy for families table that doesn't reference family_members
CREATE POLICY "Users can view families they created"
  ON families
  FOR SELECT
  TO authenticated
  USING (created_by = auth.uid());

-- 6. Create a policy for users to view families they're members of
CREATE POLICY "Users can view families they belong to"
  ON families
  FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT family_id FROM family_members WHERE user_id = auth.uid()
    )
  );