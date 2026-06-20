import '../models/our_app.dart';

/// Add your other Google Play apps here so notepad users can install them.
/// Use the package ID from the Play Store URL, e.g. com.example.myapp
/// For app icons: save a PNG in assets/apps/ and set iconAsset to its path.
const List<OurApp> ourApps = [
  OurApp(
    name: 'Smart PDF Scanner',
    description:
        'Scan documents, OCR in Hindi/English, edit, merge, split & convert PDFs.',
    packageId: 'com.vivek.pdf_scanner_app',
    iconAsset: 'assets/apps/smart_pdf_scanner.png',
  ),
];
