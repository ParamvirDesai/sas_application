import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sas_application/uniformity/CustomBottomNavBar.dart';
import 'package:sas_application/view_models/home_view_model.dart';
import 'package:stacked/stacked.dart';


import 'package:sas_application/enums.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      builder: (context, viewModel, child) => Scaffold(
        body: Home(
          key: key,
          homeViewModel: viewModel,
        ),
      ),
      viewModelBuilder: () => HomeViewModel(),
    );
  }
}

class Home extends StatefulWidget {
  final HomeViewModel homeViewModel;

  Home({Key? key, required this.homeViewModel});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:<Widget>[
              Center(
                child: TextButton(
                  onPressed: () async{
                    widget.homeViewModel.signOutAnonymously(context);
                  },
                  child: Text("Logout"),
                ),
              ),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
        ),
        onWillPop: () async => false);
  }
}
