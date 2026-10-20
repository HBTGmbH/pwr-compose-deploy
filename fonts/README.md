# Fonts for PDFs

The report service (`pwr-report-service`) reads the HBT font **Simplon Norm** from this directory, mounted at `/fonts`
(read-only), when it renders PDFs (the report preview). The font is licensed: its files must never be committed;
`.gitignore` keeps everything but this README out of Git.

Put the four `.otf` (or `.ttf`) files directly into this directory, no subdirectories:

- `SimplonNormHBT-Regular.otf`
- `SimplonNormHBT-Light.otf`
- `SimplonNormHBT-Medium.otf`
- `SimplonNormHBT-Bold.otf`

Then restart the report service (`docker compose up -d --force-recreate pwr-report-service`). Its log shows which font
it uses for each weight, e.g. `[Fonts] Simplon Norm -> Simplon Norm HBT Regular`. A missing weight falls back to Noto
Sans from the image (`[Fonts] Simplon Norm Bold -> Noto Sans Bold`).
