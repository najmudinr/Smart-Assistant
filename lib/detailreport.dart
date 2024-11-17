import 'package:flutter/material.dart';

class DetailReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                labelColor: Colors.teal,
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.teal,
                tabs: [
                  Tab(text: "Report Akhir Shift"),
                  Tab(text: "Report Antrian Truk"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildReportShiftContent(isLargeScreen),
                  _buildReportAntrianContent(isLargeScreen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportShiftContent(bool isLargeScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Berikut kami sampaikan laporan akhir shift 1 pada tanggal 19 Mei 2024",
            style: TextStyle(fontSize: isLargeScreen ? 18 : 16),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Jam mulai - Jam Selesai",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Gudang", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("07:00 - 15:00",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.teal)),
              Text("Gudang Multi Guna",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.teal)),
            ],
          ),
          SizedBox(height: 8),
          Text("Kepala Regu", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text("Rifky Isyarah",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
          SizedBox(height: 16),
          Text("Detail Rincian Personel :",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
          _buildPersonelDetail(isLargeScreen),
          SizedBox(height: 16),
          Text("Rekap Pengeluaran :",
              style: TextStyle(fontWeight: FontWeight.bold)),
          _buildRekapPengeluaranTable(isLargeScreen),
        ],
      ),
    );
  }

  Widget _buildReportAntrianContent(bool isLargeScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Laporan Antrian Truk pada tanggal 19 Mei 2024",
            style: TextStyle(fontSize: isLargeScreen ? 18 : 16),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Jam mulai - Jam Selesai",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Gudang", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("07:00 - 15:00",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.teal)),
              Text("Gudang Multi Guna",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.teal)),
            ],
          ),
          SizedBox(height: 16),
          Text("Antrian Truk Muat Akhir Shift:",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _buildAntrianTable(isLargeScreen),
          SizedBox(height: 16),
          Text("Tabel Performa Buruh:",
              style: TextStyle(fontWeight: FontWeight.bold)),
          _buildPerformaTable(isLargeScreen),
        ],
      ),
    );
  }

  Widget _buildAntrianTable(bool isLargeScreen) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.black),
        defaultColumnWidth: IntrinsicColumnWidth(),
        children: [
          _buildTableRowAntrianHeader(),
          _buildTableRowAntrian("NPK KEBOMAS", "2", "0", "2", "0"),
          _buildTableRowAntrian("PHONSKA PLUS", "3", "0", "3", "0"),
          _buildTableRowAntrian("UREA PRL NS 5KG", "0", "1", "0", "1"),
          // Add more rows as needed...
        ],
      ),
    );
  }

  TableRow _buildTableRowAntrianHeader() {
    return TableRow(
      children: [
        _buildHeaderCell("Produk"),
        _buildHeaderCell("Awal"),
        _buildHeaderCell("Masuk"),
        _buildHeaderCell("Terlayani"),
        _buildHeaderCell("Sisa"),
      ],
    );
  }

  TableRow _buildTableRowAntrian(
      String produk, String awal, String masuk, String terlayani, String sisa) {
    return TableRow(
      children: [
        _buildTableCell(produk),
        _buildTableCell(awal),
        _buildTableCell(masuk),
        _buildTableCell(terlayani),
        _buildTableCell(sisa),
      ],
    );
  }

  Widget _buildPersonelDetail(bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPersonelRow(
            "Operator Alat Berat", "1. Arbain Nawawi", isLargeScreen),
        _buildPersonelRow("Admin Loket", "Nizar Fanani", isLargeScreen),
        _buildPersonelRow("Checker", "1. M.firhad Ali", isLargeScreen),
        _buildPersonelRow("Housekeeper", "Lukman Arif Basuki", isLargeScreen),
        SizedBox(height: 8),
        Text("Jumlah Buruh", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("16 Orang",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
      ],
    );
  }

  Widget _buildPersonelRow(String title, String name, bool isLargeScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
            child: Text(name,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.teal))),
      ],
    );
  }

  Widget _buildRekapPengeluaranTable(bool isLargeScreen) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.black),
        defaultColumnWidth: IntrinsicColumnWidth(),
        children: [
          _buildTableHeader(),
          _buildTableRow(
              'NPK PHONSKA PLUS @25KG',
              '6,986.375',
              '0.000',
              '0.000',
              '7.000',
              '7.000',
              '6,979.375',
              '0.350',
              '6,979.025',
              '0.000'),
          _buildTableRow(
              'NPK 15-10-12 Sub @50KG',
              '13,086.700',
              '0.000',
              '0.000',
              '227.250',
              '87.300',
              '12,772.150',
              '3.800',
              '12,768.350',
              '0.000'),
          _buildTableRow(
              'Urea SUB @50 KG',
              '11,208.000',
              '0.000',
              '0.000',
              '395.000',
              '42.400',
              '10,770.600',
              '3.750',
              '10,766.850',
              '0.000'),
          _buildTableRow('SP 26 NS @25KG', '16,370.200', '0.000', '0.000',
              '0.000', '19.000', '16,351.200', '0.350', '16,350.850', '0.000'),
          _buildTableRow('Nitralite NS @25KG', '1,527.875', '0.000', '0.000',
              '0.000', '2.000', '1,525.875', '0.050', '1,525.825', '0.000'),
          _buildTableRow('UREA PRL NS @5KG', '602.675', '37.000', '37.000',
              '0.000', '10.000', '629.675', '9.800', '619.875', '0.000'),
          _buildTableRow('Nitralite NS @25KG', '64.400', '0.000', '0.000',
              '0.000', '2.000', '62.400', '53.400', '9.000', '0.000'),
          _buildTableRow('UREA PRL NS @5KG', '774.450', '0.000', '0.000',
              '9.000', '9.000', '765.450', '1.000', '764.450', '0.000'),
          _buildTableRow('SP 26 NS @25KG', '91.350', '0.000', '0.000', '13.000',
              '13.000', '78.350', '0.300', '78.050', '0.000'),
          _buildTableRow('ZA PRL NS @50KG', '3,617.000', '29.000', '29.000',
              '0.000', '43.000', '3,631.000', '43.000', '3,588.000', '0.000'),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        _buildHeaderCell("NAMA BARANG"),
        _buildHeaderCell("STOCK AWAL"),
        _buildHeaderCell("MUTASI MASUK"),
        _buildHeaderCell("MUTASI KELUAR"),
        _buildHeaderCell("GUDANG MULTI GUNA"),
        _buildHeaderCell("TERMINAL PELABUHAN"),
        _buildHeaderCell("SISA STOCK"),
        _buildHeaderCell("LOADING ORDER"),
        _buildHeaderCell("STOCK NYATA"),
        _buildHeaderCell("SUSUT"),
      ],
    );
  }

  TableRow _buildTableRow(
      String namaBarang,
      String stockAwal,
      String mutasiMasuk,
      String mutasiKeluar,
      String gudangMultiGuna,
      String terminalPelabuhan,
      String sisaStock,
      String loadingOrder,
      String stockNyata,
      String susut) {
    return TableRow(
      children: [
        _buildTableCell(namaBarang),
        _buildTableCell(stockAwal),
        _buildTableCell(mutasiMasuk),
        _buildTableCell(mutasiKeluar),
        _buildTableCell(gudangMultiGuna),
        _buildTableCell(terminalPelabuhan),
        _buildTableCell(sisaStock),
        _buildTableCell(loadingOrder),
        _buildTableCell(stockNyata),
        _buildTableCell(susut),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text),
    );
  }
}

Widget _buildPerformaTable(bool isLargeScreen) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: ConstrainedBox(
      constraints:
          BoxConstraints(minWidth: 300), // Set minimum width for the table
      child: Table(
        border: TableBorder.all(color: Colors.black),
        columnWidths: {
          0: FixedColumnWidth(
              200), // Ensure sufficient width for the first column
          1: FixedColumnWidth(
              100), // Ensure sufficient width for the second column
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _buildTableRow("Target Kehadiran Buruh", "18"),
          _buildTableRow("Realisasi Kehadiran Buruh", "11"),
          _buildTableRow("Kemampuan Muat", "630"),
          _buildTableRow("Realisasi Muat", "800,95"),
          _buildTableRow("Persentase", "127,134%"),
        ],
      ),
    ),
  );
}

TableRow _buildTableRow(String leftText, String rightText) {
  return TableRow(
    children: [
      _buildTableCell(leftText),
      _buildTableCell(rightText),
    ],
  );
}

Widget _buildTableCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      style: TextStyle(fontSize: 10),
      textAlign: TextAlign.center,
    ),
  );
}
