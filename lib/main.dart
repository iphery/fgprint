import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _getPrinters() async {
    _printers = await Printing.listPrinters();
    setState(() {
      showList = true;
    });
  }

  Future<void> silentPrint(message) async {
    // Membuat dokumen PDF untuk mencetak teks langsung

    final pdf = pw.Document();
    final customPaperSize = PdfPageFormat(82, 200);
    pdf.addPage(
      pw.Page(
        pageFormat: customPaperSize, // Set the custom paper size here
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Apotek Bekul',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text('Jl Apa kaden adane', style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),

              // Date & Order Number
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [pw.Text("10/10/2025"), pw.Text('SO32483099')],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [pw.Text('Putu Hery')],
              ),
              pw.Divider(thickness: 0.5),

              // Headers
              pw.Row(
                children: [
                  pw.Expanded(
                      flex: 15,
                      child: pw.Text('No', textAlign: pw.TextAlign.left)),
                  pw.Expanded(
                      flex: 15,
                      child: pw.Text('Qty', textAlign: pw.TextAlign.center)),
                  pw.Expanded(
                      flex: 35,
                      child: pw.Text('Harga', textAlign: pw.TextAlign.right)),
                  pw.Expanded(
                      flex: 35,
                      child: pw.Text('Total', textAlign: pw.TextAlign.right)),
                ],
              ),
              pw.Divider(thickness: 0.5),

              // Product Rows
              pw.Row(
                children: [
                  pw.Expanded(
                      flex: 15,
                      child: pw.Text('1', textAlign: pw.TextAlign.left)),
                  pw.Expanded(
                      flex: 15,
                      child: pw.Text('2 PCS', textAlign: pw.TextAlign.center)),
                  pw.Expanded(
                      flex: 35,
                      child:
                          pw.Text('x 10.000', textAlign: pw.TextAlign.right)),
                  pw.Expanded(
                      flex: 35,
                      child: pw.Text('20.000', textAlign: pw.TextAlign.right)),
                ],
              ),
              pw.Divider(thickness: 0.5),

              // Summary
              pw.Row(
                children: [pw.Text('Total Item: 1')],
              ),
              pw.Divider(thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [pw.Text('DISC'), pw.Text('0')],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [pw.Text('TOTAL'), pw.Text('20.000')],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [pw.Text('TUNAI'), pw.Text('20.000')],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [pw.Text('KEMBALIAN'), pw.Text('0')],
              ),
            ],
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

  Future<void> silentPrint1() async {
    // Membuat dokumen PDF untuk mencetak teks langsung

    final pdf = pw.Document();
    final customPaperSize = PdfPageFormat(82, 200);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text("Apotek Bekul",
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(
                child: pw.Text("Jl Apa kaden adane",
                    style: pw.TextStyle(fontSize: 9)),
              ),
              pw.Divider(thickness: 0.5),

              // 🛒 TABLE START
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: pw.FixedColumnWidth(20), // No
                  1: pw.FixedColumnWidth(30), // Qty
                  2: pw.FlexColumnWidth(1), // Product Name
                  3: pw.FixedColumnWidth(40), // Price
                  4: pw.FixedColumnWidth(50), // Total
                },
                children: [
                  // 🔹 HEADER ROW
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          child:
                              pw.Text("No", style: pw.TextStyle(fontSize: 9)),
                          padding: pw.EdgeInsets.all(3)),
                      pw.Padding(
                          child:
                              pw.Text("Qty", style: pw.TextStyle(fontSize: 9)),
                          padding: pw.EdgeInsets.all(3)),
                      pw.Padding(
                          child: pw.Text("Kode / Nama Produk",
                              style: pw.TextStyle(fontSize: 9)),
                          padding: pw.EdgeInsets.all(3)),
                      pw.Padding(
                          child: pw.Text("Harga",
                              style: pw.TextStyle(fontSize: 9)),
                          padding: pw.EdgeInsets.all(3)),
                      pw.Padding(
                          child: pw.Text("Total",
                              style: pw.TextStyle(fontSize: 9)),
                          padding: pw.EdgeInsets.all(3)),
                    ],
                  ),

                  // 🔹 PRODUCT 1 - DESCRIPTION ROW (MERGED)
                  pw.TableRow(
                    children: [
                      pw.Container(), // Empty
                      pw.Container(), // Empty
                      pw.Padding(
                        padding: pw.EdgeInsets.all(3),
                        child: pw.Text(
                          "NIVEA SUN AFTER SUN MOISTURE 200ML",
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Container(), // Empty
                      pw.Container(), // Empty
                    ],
                  ),

                  // 🔹 PRODUCT 1 - DETAILS ROW
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          child: pw.Text("1", style: pw.TextStyle(fontSize: 9)),
                          padding: pw.EdgeInsets.all(3)),
                      pw.Padding(
                          child: pw.Text("2 PCS",
                              style: pw.TextStyle(fontSize: 9)),
                          padding: pw.EdgeInsets.all(3)),
                      pw.Padding(
                          child: pw.Text("", style: pw.TextStyle(fontSize: 9)),
                          padding: pw.EdgeInsets.all(3)), // Empty
                      pw.Padding(
                          child: pw.Text("x 10.000",
                              style: pw.TextStyle(fontSize: 9)),
                          padding: pw.EdgeInsets.all(3)),
                      pw.Padding(
                          child: pw.Text("20.000",
                              style: pw.TextStyle(fontSize: 9)),
                          padding: pw.EdgeInsets.all(3)),
                    ],
                  ),
                ],
              ),
              // 🛒 TABLE END

              pw.Divider(thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TOTAL:",
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text("20.000", style: pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TUNAI:",
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text("50.000", style: pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("KEMBALIAN:",
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text("30.000", style: pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.Divider(thickness: 0.5),
              pw.Center(
                  child: pw.Text("Terima Kasih",
                      style: pw.TextStyle(fontSize: 9))),
            ],
          );
        },
      ),
    );

    final List<Printer> printerList = await Printing.listPrinters();
    final selectedPrinter = printerList.firstWhere(
      (p) => p.name == selectedPrinterName && p.url == selectedPrinterUrl,
    );
    print(selectedPrinter.name);
    await Printing.directPrintPdf(
      printer: selectedPrinter,
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
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
    print(selectedPrinter.name);
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
      selectedPrinterName = printerName ?? "";
      selectedPrinterUrl = printerUrl ?? "";
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
                  const Text('Connected to : '),
                  const SizedBox(
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
                      child: Container(
                        padding: EdgeInsets.only(left: 15),
                        color: Colors.grey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("${index + 1}"),
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(printer.name),
                                Text(printer.model ?? "No description"),
                                const SizedBox(
                                  height: 5,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                  onTap: () => {silentPrint1()},
                  child: const Text('Test Print')),
              Container(
                child: Column(
                  children: [
                    Text('Apotek Bekul'),
                    Text('Jl Apa kaden adane'),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("10/10/2025"), Text('SO32483099')],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Text('Putu Hery')],
                    ),
                    Divider(
                      thickness: 0.5, // Thin hairline
                      color: Colors.grey, // Adjust color as needed
                      height: 1, // Minimal height
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 20, // 15% width
                        ),
                        Expanded(
                          // flex: 15, // 15% width
                          child: Center(child: Text('Kode / Nama Produk')),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            flex: 15, // 15% width
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('No'),
                            )),
                        Expanded(
                          flex: 15, // 15% width
                          child: Center(child: Text('Qty')),
                        ),
                        Expanded(
                          flex: 35, // 35% width
                          child: Align(
                            alignment: Alignment
                                .centerRight, // Align text to the right
                            child: Text('Harga'),
                          ),
                        ),
                        Expanded(
                          flex: 35, // 35% width
                          child: Align(
                            alignment: Alignment
                                .centerRight, // Align text to the right
                            child: Text('Total'),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 0.5, // Thin hairline
                      color: Colors.grey, // Adjust color as needed
                      height: 1, // Minimal height
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 20, // 15% width
                          child: Center(child: Text('1')),
                        ),
                        Expanded(
                          // flex: 15, // 15% width
                          child: Center(
                              child:
                                  Text('NIVEA SUN AFTER SUN MOISTURE 200ML')),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 15, // 15% width
                          child: Center(child: Text('2')),
                        ),
                        Expanded(
                          flex: 15, // 15% width
                          child: Center(child: Text('PCS')),
                        ),
                        Expanded(
                          flex: 35, // 35% width
                          child: Align(
                            alignment: Alignment
                                .centerRight, // Align text to the right
                            child: Text('x 10.000'),
                          ),
                        ),
                        Expanded(
                          flex: 35, // 35% width
                          child: Align(
                            alignment: Alignment
                                .centerRight, // Align text to the right
                            child: Text('20.000'),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 0.5, // Thin hairline
                      color: Colors.grey, // Adjust color as needed
                      height: 1, // Minimal height
                    ),
                    Row(
                      children: [
                        Text('Total Item : ${"1"}'),
                      ],
                    ),
                    Divider(
                      thickness: 0.5, // Thin hairline
                      color: Colors.grey, // Adjust color as needed
                      height: 1, // Minimal height
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('DISC'), Text('0')],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('TOTAL'), Text('0')],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('TUNAI'), Text('0')],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('KEMBALIAN'), Text('0')],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

// Function to print message using the printing package
Future<void> printMessage(String text) async {
  print(text);
}
