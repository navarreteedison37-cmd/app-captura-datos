# App Captura de Datos → Word automático

App en Flutter que:
1. Toma una foto (o carga varias a la vez).
2. Lee el texto con OCR (Google ML Kit, funciona sin internet).
3. Extrae 9 campos: RUC, Nombre/Razón Social, N° de Acta, N° de Carta,
   Recepcionado por, Vínculo, DNI, Fecha de Inicio, Fecha y Hora.
4. Te deja validar/corregir esos campos.
5. La PRIMERA vez que abres la app, pregunta si vas a trabajar
   "Inspección Laboral" o "Control de Ingresos" (una sola vez).
6. Según esa elección, busca automáticamente la plantilla Word correcta
   y la rellena con los datos, generando el documento final.

---

## PASO 1 — Subir este proyecto a GitHub (sin necesitar Git instalado)

**Opción A — Con GitHub Desktop (recomendada, es 100% con clics, sin comandos):**
1. Descarga GitHub Desktop (gratis): https://desktop.github.com
2. Instálalo y entra con tu cuenta de GitHub.
3. En GitHub Desktop: `File > New repository`. Ponle un nombre, por ejemplo
   `app-captura-datos`.
4. Te va a mostrar la carpeta local del repositorio (algo como
   `C:\Users\TuNombre\Documents\GitHub\app-captura-datos`).
5. Copia **todo el contenido** de esta carpeta que te entregué (`app_captura/`)
   dentro de esa carpeta del repositorio (los archivos deben quedar
   directamente ahí, no dentro de una subcarpeta extra).
6. Vuelve a GitHub Desktop: vas a ver todos los archivos nuevos listados.
   Escribe un mensaje como "Primera versión" y presiona **Commit to main**.
7. Presiona **Publish repository** (arriba).

**Opción B — Subiendo por la web de GitHub (sin instalar nada):**
1. Entra a github.com con tu cuenta, crea un repositorio nuevo (botón verde
   "New").
2. Dentro del repositorio, click en "Add file" > "Upload files".
3. Arrastra TODA la carpeta `app_captura` (o todos sus archivos y
   subcarpetas) a la zona de carga. Nota: para que las subcarpetas
   (`lib/`, `assets/`, `.github/`) se respeten, arrastra la carpeta
   completa, no los archivos sueltos.
4. Presiona "Commit changes".

⚠️ Importante: la carpeta `.github` empieza con un punto y a veces los
exploradores de archivos la ocultan. En GitHub Desktop no hay problema; si
usas la web y no la ves, actívala en tu explorador de Windows con
"Ver > Elementos ocultos".

---

## PASO 2 — Dejar que GitHub compile el APK

En cuanto subas los archivos (Commit/Publish), GitHub detecta el archivo
`.github/workflows/build.yml` y arranca la compilación solo.

1. Ve a tu repositorio en github.com.
2. Click en la pestaña **Actions** (arriba).
3. Vas a ver un proceso corriendo llamado "Compilar APK" (tarda entre 5 y
   10 minutos la primera vez).
4. Cuando termine (ícono verde ✔), entra a esa ejecución y baja hasta
   **Artifacts**. Ahí vas a ver `app-release-apk` — descárgalo (es un .zip
   que contiene el .apk).
5. Ese .apk lo pasas a tu celular Android (por USB, Drive, WhatsApp, etc.)
   y lo instalas (Android te va a pedir permitir "instalar de fuentes
   desconocidas" la primera vez).

---

## PASO 3 — Reemplazar las plantillas Word por las tuyas reales

Las plantillas de ejemplo están en `assets/templates/`:
- `inspeccion_laboral.docx`
- `control_ingresos.docx`

Para usar TUS plantillas reales:
1. Abre tu plantilla en Word.
2. En el lugar donde debe ir cada dato, escribe la etiqueta exacta
   (incluyendo las dobles llaves `{{ }}`):

   | Dato                    | Etiqueta a escribir en Word |
   |--------------------------|------------------------------|
   | RUC                      | `{{ruc}}`                    |
   | Nombre o Razón Social    | `{{nombre}}`                 |
   | N° de Acta               | `{{numero_acta}}`            |
   | N° de Carta              | `{{numero_carta}}`           |
   | Recepcionado por         | `{{recepcionado_por}}`       |
   | Vínculo                  | `{{vinculo}}`                |
   | DNI                      | `{{dni}}`                    |
   | Fecha de Inicio          | `{{fecha_inicio}}`           |
   | Fecha y Hora             | `{{fecha_hora}}`             |

3. Guarda el archivo con el MISMO nombre que ya tiene
   (`inspeccion_laboral.docx` o `control_ingresos.docx`) y reemplázalo
   dentro de `assets/templates/` en tu repositorio (puedes volver a
   "Upload files" en GitHub, o arrastrarlo en GitHub Desktop).
4. Sube el cambio (commit) — GitHub va a recompilar el APK solo, con tu
   plantilla nueva ya integrada.

**Consejo para que la etiqueta no se "rompa":** escribe `{{ruc}}` de
corrido, sin pausas ni cambios de formato a la mitad (sin poner parte en
negrita y parte no). Si Word le cambia el formato automáticamente a mitad
de la etiqueta, puede dividirla en pedazos y no se reconocería. Si eso
pasa, borra la etiqueta completa y vuelve a escribirla de una sola vez.

---

## PASO 4 — Ajustar la lectura (OCR) a tu ficha real

El archivo `lib/services/parser_service.dart` es el que "entiende" el
texto que lee la cámara y lo separa en los 9 campos. Ya tiene patrones
flexibles (ej. reconoce "RUC:", "Nº de Acta", etc.), pero cada ficha física
es distinta.

Si al probar la app algún campo no se llena bien, mándame una foto de tu
ficha real (o el texto que lee) y ajusto el patrón exacto de ese campo.

---

## Estructura del proyecto

```
app_captura/
├── lib/
│   ├── main.dart                      # Punto de entrada
│   ├── models/document_data.dart      # Los 9 campos
│   ├── services/
│   │   ├── ocr_service.dart           # Lee texto de la foto
│   │   ├── parser_service.dart        # Texto -> campos (AJUSTAR AQUI)
│   │   ├── modo_service.dart          # Recuerda el modo elegido
│   │   └── template_service.dart      # Rellena el Word automaticamente
│   └── screens/
│       ├── mode_selection_screen.dart # Pregunta unica (Inspeccion/Control)
│       ├── home_screen.dart
│       ├── capture_screen.dart        # Foto individual
│       ├── bulk_upload_screen.dart    # Carga masiva
│       └── validation_screen.dart     # Revisar/corregir datos
├── assets/templates/                  # AQUI VAN TUS 2 PLANTILLAS WORD
├── .github/workflows/build.yml        # Compila el APK en la nube
└── pubspec.yaml                       # Dependencias
```

---

## Trabajar el proyecto desde dos computadoras

Con cualquiera de las dos opciones de subida (GitHub Desktop o la web), el
proyecto queda en la nube. Para seguir trabajando desde otra PC:
- Con GitHub Desktop: `File > Clone repository`, eliges tu repo, y ya
  tienes una copia local en esa segunda PC. Cuando hagas cambios ahí,
  "Commit" + "Push" para subirlos.
- Los cambios en cualquier PC recompilan el APK automáticamente (Paso 2).

No necesitas tener Flutter instalado en NINGUNA de las dos computadoras
si solo vas a editar textos/plantillas y dejar que GitHub compile. Flutter
local solo hace falta si en algún momento quieres ver la app corriendo en
vivo (modo desarrollo) antes de generar el APK final.
