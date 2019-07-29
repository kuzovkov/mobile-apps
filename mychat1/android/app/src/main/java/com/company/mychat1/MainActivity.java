package com.company.mychat1;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.yandex.mapkit.MapKitFactory;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    MapKitFactory.setApiKey("d2052e59-2f84-4b97-ad2a-fa9f103c2e6e");
    GeneratedPluginRegistrant.registerWith(this);
  }
}
