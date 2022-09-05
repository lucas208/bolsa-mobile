import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance/stock_price?key=692fd151";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.amber),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final searchController = TextEditingController();
  final displayResultController = TextEditingController();

  double price;
  String symbol;

  void _symbolChange(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    symbol = text;
  }

  void _clearAll() {
    searchController.text = "";
    displayResultController.text = "";
  }

  void _clearSearch() {
    searchController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text("\$ Bolsa Brasil \$"),
            centerTitle: true,
            backgroundColor: Colors.amber),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(
                      child: Text(
                    "Carregando dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "Erro ao carregar dados...",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.amber),
                          buildTextFormField("Título", searchController, _symbolChange),
                          Divider(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 30),
                              primary: Colors.amber,
                            ),
                            onPressed: () async {
                              _clearSearch();
                              if (symbol != null) {
                                try {
                                  String request ="https://api.hgbrasil.com/finance/stock_price?key=692fd151&symbol=" + symbol;
                                  http.Response response = await http.get(request);
                                  Map<String, dynamic> snapshot = json.decode(response.body);
                                  price = snapshot["results"][symbol.toUpperCase()]["price"];
                                  symbol = snapshot["results"][symbol.toUpperCase()]["name"];
                                  displayResultController.text = symbol + ", R\$ " + price.toStringAsFixed(2);
                                } catch (e) {
                                  print(e);
                                  displayResultController.text = "Código inválido";
                                }
                              } else {
                                displayResultController.text = "Campo de Título vazio";
                              }
                            },
                            child: Text('Buscar'),
                          ),
                          Divider(),
                          TextField(
                              controller: displayResultController,
                              decoration: InputDecoration.collapsed(
                                  hintText: "Insira o cód. do Título",
                                  fillColor: Colors.amber),
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 30),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.none)
                        ],
                      ),
                    );
                  }
              }
            }));
  }

  Widget buildTextFormField(
      String label, TextEditingController controller, Function f) {
    return TextField(
      onChanged: f,
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.amber),
          border: OutlineInputBorder()),
      style: TextStyle(color: Colors.amber, fontSize: 25.0),
      keyboardType: TextInputType.text,
    );
  }
}
