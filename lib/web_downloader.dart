import 'dart:html' as html;
import 'dart:typed_data';

void downloadQrCode(Uint8List pngBytes) {
  final blob = html.Blob([pngBytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "qr_code_${DateTime.now().millisecondsSinceEpoch}.png")
    ..click();
  html.Url.revokeObjectUrl(url);
}
