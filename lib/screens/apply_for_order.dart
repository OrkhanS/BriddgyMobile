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

  // TODO: Add _isRewardedAdReady
  bool _isRewardedAdReady;

  // TODO: Implement _loadRewardedAd()
  void _loadRewardedAd() {
    RewardedVideoAd.instance.load(
      targetingInfo: MobileAdTargetingInfo(),
      adUnitId: AdManager.rewardedAdUnitId,
    );
  }

  // TODO: Implement _onRewardedAdEvent()
  void _onRewardedAdEvent(RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
    switch (event) {
      case RewardedVideoAdEvent.loaded:
        setState(() {
          _isRewardedAdReady = true;
        });
        break;
      case RewardedVideoAdEvent.closed:
        setState(() {
          _isRewardedAdReady = false;
        });
        _loadRewardedAd();
        break;
      case RewardedVideoAdEvent.failedToLoad:
        setState(() {
          _isRewardedAdReady = false;
        });
        print('Failed to load a rewarded ad');
        break;
      case RewardedVideoAdEvent.rewarded:
        break;
      default:
      // do nothing
    }
  }

  @override
  void initState() {
    // TODO: Initialize _isRewardedAdReady
    _isRewardedAdReady = false;

    // TODO: Set Rewarded Ad event listener
    RewardedVideoAd.instance.listener = _onRewardedAdEvent;

    // TODO: Load a Rewarded Ad
    _loadRewardedAd();
    RewardedVideoAd.instance.show();
  }

  @override
  void dispose() {
    // TODO: Dispose BannerAd object
    RewardedVideoAd.instance.listener = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Container(
                width: double.infinity,
                height: 40,
                color: Colors.teal,
              ),
            )
          ],
        ),
      ),
    );
  }
}
