./execute-in-pods.sh "controller.devfile.io/devworkspace_name=superheroes-workshop-seeded" "mvn clean install -Pcomplete -DskipTests -f /projects/superheroes-workshop-seeded/quarkus-workshop-super-heroes/pom.xml"
#./execute-in-pods.sh "controller.devfile.io/devworkspace_name=superheroes-workshop-seeded" "cd /projects/superheroes-workshop-seeded && git stash && git pull --rebase"
