# pushes src/wwwroot to gh-pages branch

param ([string] $env = "local")

$msg = 'gh-pages.ps1: tests/client/wwwroot -> gh-pages'
$gitURL = "https://github.com/intellifactory/Bolero"

write-host -foregroundColor "green" "=====> $msg"

function clearDir() {
  rm -r build/gh-pages -errorAction ignore
}

if ($env -eq "appveyor") {
  clearDir
  $d = mkdir -force build
  git clone $gitURL build/gh-pages
  cd build/gh-pages
  git config credential.helper "store --file=.git/credentials"
  $t = $env:GH_TOKEN
  $cred = "https://" + $t + ":@github.com"
  $d = pwd
  [System.IO.File]::WriteAllText("$pwd/.git/credentials", $cred)
  git config user.name "AppVeyor"
  git config user.email "websharper-support@intellifactory.com"
} else {
  clearDir
  cd build
  git clone .. gh-pages
  cd gh-pages
}

git checkout gh-pages
git rm -rf *
cp -r -force ../../tests/client/wwwroot/* .
(get-content '.\index.html').replace('<base href="/"', '<base href="/Bolero/"') | set-content '.\index.html'
cp -r -force ../../tests/client/bin/Release/netstandard2.0/dist/_framework .
cp -r -force ../../tests/client/bin/Release/netstandard2.0/dist/_content .
git add . 2>git.log
git commit --amend -am $msg
git push -f -u origin gh-pages
cd ../..
clearDir
write-host -foregroundColor "green" "=====> DONE"
