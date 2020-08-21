import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ad_manager.dart';

class ApplyForOrderScreen extends StatefulWidget {
  @override
  _ApplyForOrderScreenState createState() => _ApplyForOrderScreenState();
}

class _ApplyForOrderScreenState extends State<ApplyForOrderScreen> {
  Future<void> _initAdMob() {
    // TODO: Initialize AdMob SDK
    return FirebaseAdMob.instance.initialize(appId: AdManager.appId);
  }

  // TODO: Add _bannerAd
  BannerAd _bannerAd;

  // TODO: Implement _loadBannerAd()
  void _loadBannerAd() {
    _bannerAd
      ..load()
      ..show(anchorType: AnchorType.bottom);
  }

  @override
  void initState() {
    // TODO: Initialize _bannerAd
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.banner,
    );

    // TODO: Load a Banner Ad
    _loadBannerAd();

    super.initState();
  }

  @override
  void dispose() {
    // TODO: Dispose BannerAd object
    _bannerAd?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.red,
            )
          ],
        ),
      ),
    );
  }
}
