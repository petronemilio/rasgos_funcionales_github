## Introducción a GitHub

¿Qué vamos a ver durante la clase? 

1. Breve introducción a los sistemas de control de versiones (VCS, por sus siglas en inglés). ¿Porqué usar sistemas de control de versiones?

2.  SCV locales: Git
Comandos básicos de Git. Workflow. Conceptos útiles para entender cómo funciona el programa.

3.  SCV remotos : Github
 Un par de comandos más en github. Lo mínimo y suficiente para usar una cuenta.
 Hacer introducción a hello world!

4. Ventajas de usar Git y Github: reproducibilidad, organziación
 
5. Organización de un repositorio y de un proyecto de investigación.

6.  Ejercicio con el repositorio.

#### Sistemas de control de versiones

Los **VCS** son una herramienta para registrar y organizar cambios en una serie de archivos y directorios. Los VCS hacen una base de datos con el historial de versiones de un proyecto. Git y Github son ejemplos de VCS pero no son los únicos programas que permiten hacer un control de versiones (por ejemplo, [mercurial](https://www.mercurial-scm.org/about) o [Subversion](http://subversion.apache.org/)). 

#### VCS locales
[Git](https://gitforwindows.org/) es un VCS local con distribución en windows, mac y linux. Fue diseñado por Linus Trovalds para la creación de Linux y es de código abierto. 

![Linus Trovalds... chico listo!](../meta/linus_trovalds.png )

Los archivos y directorios que están sujetos a un historial de versiones en git se guardan de forma **local**. En otras palabras, solo existen en tú computadora. Pero, ¿cómo funciona git?

Lo primero que hay que hacer en git es definir el directorio que estará sujeto a un historial de versiones, es decir un **repositorio** (¡¡¡Ding, ding ding!!!). ¿Cuál es la forma más común de organizar un repositorio?


A continuación vemos el flujo de trabajo en git:

1. **init:** `$ git init` 
     `Initilized empty Git repository in /rasgos_funcionales_github/.git` 
2. Realizar cambios en el repositorio: crear archivos nuevos, cambiar o editar archivos.
3. `$ git status` 
4. **add:**`$ git add [FILENAME]`: Agrega los archivos que quieres que git les siga la pista.
5. **commit:**`$ git commit -m "mensaje sobre los cambios"`: Después de modificar un archivo hay que dejar un mensaje claro y preciso sobre las modificaciones realizadas a un archivo.
6. Repetir a partir del punto 2.
![El workflow de git](../meta/version_control.png)

Esto podría parecer tedioso. Aprender los comandos y repetirlo podría quitar mucho tiempo.... ¿cuáles serían las ventajas de utilizar git?

### Github

Es un sitio web para trabajar y colaborar en proyectos que están sujetos a control de versiones basado en **git** y que guarda los repositorios en la red.
Con el flujo de trabajo de git y entendiedo que es un commit y que es un branch ahora hay que agregar un par de comandos claves en github:
1. **fork**
1. **push**
2. **pull** y **pull request**


Manos a la obra con el primer [tutorial](https://guides.github.com/activities/hello-world/)

Buena guía del [workflow](https://guides.github.com/introduction/flow/)

El proceso general de trabajar en repositorios remotos es:

**Pull** > Hacer cambios > **Add** > **Commit** > **Push** > Repeat

Pull: This downloads any file updates from the GitHub repository and tries to incorporate them into your local copy. This step is often forgotten, which can cause some headaches later on, so try to remember to start your session with a pull. You can pull the latest code from GitHub with the blue Pull button in the Git tab of the (usually) top-right panel in RStudio.
Make changes: At this point you can add more files, change files that exist, or delete files you don’t need any more. Just remember to save your changes.
Add: The add command instructs Git that you would like to make Git aware of any changes you made to files on your local repository (saving isn’t enough in this case). After you have made your changes (and saved them!), add them by clicking the “Staged” box next to the file name in the Git tab of RStudio.

Push: Finally, you want to move those committed changes up to the remote (GitHub) repository. The green Push button will send any changes to GitHub. Note that you will need your GitHub ID and password to push changes to the remote repository. Also note that if you are pushing to a GitHub repository that you did not create, you will need to be added as a collaborator by the repository owner.
Repeat: This step is pretty self-explanatory.


`## install if needed (do this exactly once)` 
`## install.packages("usethis")`
`library(usethis)`
`use_git_config(user.name = "Jane Doe", user.email = "jane@example.org") `
