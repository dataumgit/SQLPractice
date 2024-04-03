HiveSqlPractice


git clone https://github.com/dataumgit/SQLPractice.git

git config user.name "dataumgit"
git config user.email "dataum1@sina.cn"


error: src refspec master does not match any
error: failed to push some refs to 'https://github.com/dataumgit/SQLPractice.git'

If your branch contains no commits (check this by seeing whether git log produces an error message), create a commit before you can push.

git add .
git commit -m "Initial commit"
git push -u origin main
