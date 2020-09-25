class Beacon
{
    final String name;
    final String uuid;
    final String mac;
    final String major;
    final String minor;
    final String distance;
    final String rssi;
    final String txPower;
    final String time;

    Beacon({
        this.name,
        this.uuid,
        this.mac,
        this.major,
        this.minor,
        this.distance,
        this.rssi,
        this.txPower,
        this.time
    });

    Map<dynamic, dynamic> toJson() => {
        'name': name,
        'uuid': uuid,
        'mac': mac,
        'major': major,
        'minor': minor,
        'distance': distance,
        'rssi': rssi,
        'txPower': txPower,
        'time': time,
    };
}
