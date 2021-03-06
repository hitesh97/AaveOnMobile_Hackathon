import 'dart:convert';

import 'package:AaveOnMobile/app/aave/common_widgets/collateral_toggle_success_modal.dart';
import 'package:AaveOnMobile/app/aave/common_widgets/switch_apy_success_modal.dart';
import 'package:AaveOnMobile/app/crypto/broadcast_failed_modal.dart';
import 'package:AaveOnMobile/app/crypto/is_broadcasting_modal.dart';
import 'package:AaveOnMobile/app/crypto_utils/gas_utls.dart';
import 'package:AaveOnMobile/app/models/Wallet.dart';
import 'package:AaveOnMobile/app/wallet/wallet_data_viewmodel.dart';
import 'package:AaveOnMobile/common_widgets/crypto_icon.dart';
import 'package:AaveOnMobile/common_widgets/wallet_address_text_widget.dart';
import 'package:AaveOnMobile/crypto_utils/crypto_utls.dart';
import 'package:AaveOnMobile/local_password_viewmodel.dart';
import 'package:AaveOnMobile/utils/cache.dart';
import 'package:AaveOnMobile/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/credentials.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CollateralToggleReviewModal extends StatefulWidget {
  final Map localTxObj;
  final Future collateralToggleApiResponse;
  final Function() onDonePressed;

  CollateralToggleReviewModal({
    @required this.localTxObj,
    @required this.collateralToggleApiResponse,
    @required this.onDonePressed,
  });
  @override
  _CollateralToggleReviewModalState createState() =>
      _CollateralToggleReviewModalState();
}

class _CollateralToggleReviewModalState
    extends State<CollateralToggleReviewModal> {
  Future _futureToBuild;
  bool isBroadcasting = false;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    _futureToBuild = widget.collateralToggleApiResponse;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final walletData = Provider.of<WalletDataProvider>(context);
    final localPasswordProvider = Provider.of<LocalPasswordProvider>(context);
    final appCacheProvider = Provider.of<AppCache>(context, listen: false);

    WalletModel activeWallet = walletData.activeWallet;

    Future _signAndBroadcast(depositApiResponse) async {
      String _walletPrivateKeyDecrypted;

      if (activeWallet.privateKeyDecrypted == null) {
        final cryptor = new PlatformStringCryptor();
        final String key = await cryptor.generateKeyFromPassword(
            localPasswordProvider.appPassword, localPasswordProvider.localSalt);
        _walletPrivateKeyDecrypted =
            await cryptor.decrypt(activeWallet.privateKeyEncrypted, key);
      } else {
        _walletPrivateKeyDecrypted = activeWallet.privateKeyDecrypted;
      }

      var signedTransaction = await signTransaction(depositApiResponse,
          EthPrivateKey.fromHex(_walletPrivateKeyDecrypted));
      var broadcastApiResponse = await broadCastTransaction(
          signedTransaction, activeWallet.walletAddress);
      return broadcastApiResponse;
    }

    return FutureBuilder(
      future: _futureToBuild,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text("none");
          case ConnectionState.active:
          case ConnectionState.waiting:
            if (isBroadcasting) {
              return Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: IsBroadcastingModal());
            } else {
              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  // heightFactor: 10,
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return Container();

          case ConnectionState.done:
            if (snapshot.data.statusCode == 200 &&
                snapshot.hasData &&
                !snapshot.hasError) {
              var objApiResponse;
              String _operation;

              try {
                objApiResponse = jsonDecode(snapshot.data.body.toString());
                _operation = objApiResponse["operation"];
              } on Exception catch (exp) {
                return BroadcastFailedModal(
                  onDonePressed: () {
                    widget.onDonePressed();
                  },
                );
              } catch (e) {
                return BroadcastFailedModal(
                  onDonePressed: () {
                    widget.onDonePressed();
                  },
                );
              }
              // String operation =
              //     jsonDecode(snapshot.data.body)["operation"].toString();

              if (_operation.toLowerCase() ==
                  "TOGGLECOLLATERAL".toLowerCase()) {
                var collateralToggleApiResponseObj =
                    jsonDecode(snapshot.data.body);
                widget.localTxObj["collateralToggleApiResponseObj"] =
                    collateralToggleApiResponseObj;

                print(collateralToggleApiResponseObj);

                if (collateralToggleApiResponseObj["isError"] != true) {
                  String _onOffString = widget.localTxObj["txnParamsByUser"]
                          ["useAsCollateral"]
                      ? "On"
                      : "Off";

                  String token = widget
                      .localTxObj["collateralToggleApiResponseObj"]["token"];

                  String rawSvgString = Jdenticon.toSvg(widget
                      .localTxObj["collateralToggleApiResponseObj"]["to_addr"]
                      .toString());

                  return Container(
                      padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            "Confirm ",
                            // depositApiResponseObj["token"].toString(),
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 32,
                                width: 32,
                                child: SvgPicture.string(rawSvgString),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              WalletAddressText(
                                walletAddress: widget.localTxObj[
                                        "collateralToggleApiResponseObj"]
                                    ["to_addr"],
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Divider(),
                          SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  "Turning $_onOffString collateral for $token",
                                  style: TextStyle(
                                      textBaseline: TextBaseline.alphabetic,
                                      // color: Colours.green,
                                      foreground: Paint()
                                        ..shader = linearGradient,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CryptoIcon(
                                      height: 36,
                                      width: 36,
                                      token: token,
                                    ),
                                    Text(
                                      " $token",
                                      style: TextStyle(
                                        textBaseline: TextBaseline.alphabetic,
                                        color: Colours.green,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 25,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          FutureBuilder(
                            future: GasUtils().getGasPriceInEthAndUsd(
                                collateralToggleApiResponseObj["rawTx"]
                                    ["gasLimit"],
                                collateralToggleApiResponseObj["rawTx"]
                                    ["gasPrice"]),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                  return Container();
                                case ConnectionState.active:
                                  return Container();
                                case ConnectionState.waiting:
                                  return Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.08,
                                  );
                                case ConnectionState.done:
                                  Map gasFeeMap = snapshot.data;

                                  print(gasFeeMap);

                                  return Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.08,
                                    // decoration: BoxDecoration(border: Border.all()),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Max Gas Price",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2,
                                        ),
                                        Container(
                                          child: Column(
                                            // mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              FittedBox(
                                                  child: Text(
                                                      "~ ${gasFeeMap["maxGasFee"]} ETH")),
                                              FittedBox(
                                                child: Text(
                                                    "(\$${gasFeeMap["maxGasFeeInUsd"]})"),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                default:
                                  return Text("default");
                              }
                            },
                          ),
                          Divider(
                            height: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isBroadcasting = !isBroadcasting;
                                    _futureToBuild =
                                        _signAndBroadcast(snapshot.data);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: Colours.purpleGradient,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: MediaQuery.of(context).size.width * 1,
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  child: Center(
                                    child: Text(
                                      "Confirm",
                                      style: Theme.of(context).textTheme.button,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      widget.onDonePressed();
                                      Navigator.of(context).pop();
                                    },
                                    child: Center(
                                      child: Text("Cancel",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colours.text_gray,
                                              fontSize: 18)),
                                    ),
                                  ))
                            ],
                          ),
                          // SizedBox(height: 20,),
                        ],
                      ));
                }
              } else if (_operation == "BROADCAST") {
                var broadcastResponseData = jsonDecode(snapshot.data.body);
                widget.localTxObj["broadcastApiResponseObj"] =
                    broadcastResponseData;

                if (broadcastResponseData["isError"] == false) {
                  return CollateralToggleSuccessModal(
                    onDonePressed: () {
                      widget.onDonePressed();
                    },
                    localTxObj: widget.localTxObj,
                  );
                } else if (broadcastResponseData["isError"] == true) {
                  return BroadcastFailedModal(
                    onDonePressed: () {
                      widget.onDonePressed();
                    },
                  );
                } else {
                  return Text("Unknown error",
                      style: Theme.of(context)
                          .textTheme
                          .headline2
                          .copyWith(color: Colours.red));
                }
              }
            }

            return BroadcastFailedModal(
              onDonePressed: () {
                widget.onDonePressed();
              },
            );

          default:
            return Text("default");
        }
      },
    );
  }
}
