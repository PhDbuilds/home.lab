# Contributors

## Please add your name to this list

**PhDbuilds**: @PhDBuilds AKA Astronuat (pending...)

## Branching

When working on a feature, it is important to create a feature branch using the following syntax:

```bash
git checkout -b documentation/1-create-contribute-file

```
or
```bash
git checkout -b bug/23-fixed-blah-bug-yay
```
where the 1/23 prefix is the number of the Project Board issue number, if applicable

Make your changes/additions then add the change to the branch by:

```bash
git add *
git commit -m "I added a test file for used case UC-01" 
git push --set-upstream origin documentation/1-create-contribute-files
```

This will add a new branch on the server.

From here you can use the the Github application to request a pull to the main branch.  Always pick some names to review, and add the pull request.

1. Pick from the top menu "Pull Requests"
2. Select the branch you are requesting to pull
3. Click Create a Pull request
4. Add some reviewers from the right side menu
5. Once all the reviews are done and requested changes done you can merge into main and delete the feature branch.


