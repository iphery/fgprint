import 'dart:convert';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tray_manager/tray_manager.dart';

void Function(String)? onMessageReceived;
void main() {
  var handler = webSocketHandler((webSocket, _) {
    webSocket.stream.listen((message) {
      webSocket.sink.add('echo $message');
      // printMessage(message);
      if (onMessageReceived != null) {
        onMessageReceived!(message);
      }
    });
  });

  shelf_io.serve(handler, 'localhost', 8081).then((server) {
    print('Serving at ws://${server.address.host}:${server.port}');
  });

  // doWhenWindowReady(() {
  //   final win = appWindow;
  //   win.show();
  // });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FG Print',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PrinterPage(),
      //home: const MyHomePage(title: 'Flutter Demo Home Page wiw'),
    );
  }
}

class PrinterPage extends StatefulWidget {
  const PrinterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PrinterPageState createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> with TrayListener {
  List<Printer> _printers = [];
  String selectedPrinterName = "";
  String selectedPrinterUrl = "";
  bool showList = false;

  Future<void> _getPrinters() async {
    _printers = await Printing.listPrinters();
    setState(() {
      showList = true;
    });
  }

  Future<void> silentPrint(message) async {
    // Membuat dokumen PDF untuk mencetak teks langsung
    print(message);
    final pdf = pw.Document();
    final customPaperSize = PdfPageFormat(82, 200);
    pdf.addPage(
      pw.Page(
        pageFormat: customPaperSize, // Set the custom paper size here
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Name: Paul Scholes',
                    style: pw.TextStyle(fontSize: 10)),
                pw.Text('Age: 40', style: pw.TextStyle(fontSize: 10)),
              ],
            ),
          );
        },
      ),
    );

    // Ambil daftar printer yang tersedia
    final List<Printer> printers = await Printing.listPrinters();

    // if (printers.isNotEmpty) {
    //   final Printer selectedPrinter = printers[5];

    //   await Printing.directPrintPdf(
    //     printer: selectedPrinter,
    //     onLayout: (PdfPageFormat format) async => pdf.save(),
    //   );
    //   print('print berhasil');
    // } else {
    //   print("Tidak ada printer yang tersedia.");
    // }
  }

  Future<void> testPrint() async {
    // Membuat dokumen PDF untuk mencetak teks langsung

    final pdf = pw.Document();
    final customPaperSize = PdfPageFormat(82, 200);
    pdf.addPage(
      pw.Page(
        pageFormat: customPaperSize, // Set the custom paper size here
        build: (pw.Context context) {
          return pw.Center(child: pw.Text('Test Printer'));
        },
      ),
    );

    final List<Printer> printerList = await Printing.listPrinters();
    final selectedPrinter = printerList.firstWhere(
      (p) => p.name == selectedPrinterName && p.url == selectedPrinterUrl,
    );

    await Printing.directPrintPdf(
      printer: selectedPrinter,
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _initTray() async {
    await trayManager.setIcon('assets/images/tray_icon.png');
    await trayManager.setToolTip('FG Printer Tools');

    Menu menu = Menu(
      items: [
        MenuItem(key: 'show', label: 'Show'),
        MenuItem(key: 'exit', label: 'Exit'),
      ],
    );

    await trayManager.setContextMenu(menu);
  }

  Future<void> savePrinterInfo(Printer printerInfo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('printerName', printerInfo.name);
    await prefs.setString('printerUrl', printerInfo.url);
  }

  void getSelectedPrinter() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var name = prefs.getString("printerName");
    var url = prefs.getString("printerUrl");
    setState(() {
      selectedPrinterName = name ?? "";
      selectedPrinterUrl = url ?? "";
    });
  }

  Future<Printer?> getPrinterInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? printerName = prefs.getString('printerName');
    String? printerUrl = prefs.getString("printerUrl");
    setState(() {
      showList = false;
    });
    if (printerName != null && printerUrl != null) {
      final printerList = await Printing.listPrinters();
      return printerList.firstWhere(
        (p) => p.name == printerName && p.url == printerUrl,
      );
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    //_getPrinters();
    onMessageReceived = silentPrint;
    trayManager.addListener(this);
    _initTray();
    getSelectedPrinter();
  }

  @override
  void onTrayIconMouseDown() {
    appWindow.show();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show') {
      appWindow.show();
    } else if (menuItem.key == 'exit') {
      trayManager.destroy();
      appWindow.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Setup Printer'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Connected to : '),
                  SizedBox(
                    width: 5,
                  ),
                  Column(
                    children: [
                      Text(selectedPrinterName),
                    ],
                  )
                ],
              ),
              GestureDetector(
                  onTap: () => {_getPrinters()},
                  child: const Column(
                    children: [
                      Text('Find and Select Printers'),
                    ],
                  )),
              if (showList)
                ListView.builder(
                  itemCount: _printers.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final printer = _printers[index];
                    return GestureDetector(
                      onTap: () => {
                        savePrinterInfo(printer).then((e) => {getPrinterInfo()})
                      },
                      child: Column(
                        children: [
                          Text(printer.name),
                          Text(printer.model ?? "No description")
                        ],
                      ),
                    );
                  },
                ),
              GestureDetector(
                  onTap: () => {testPrint()}, child: const Text('Test Print')),
            ],
          ),
        ));
  }
}

// Function to print message using the printing package
Future<void> printMessage(String text) async {
  print(text);
}
