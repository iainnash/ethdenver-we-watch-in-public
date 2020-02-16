import {LastPersonsFulfilled, LastDevicesFulfilled} from '../generated/IOTActivity/IOTActivity';
import {PersonActivity, DeviceActivity} from '../generated/schema';

export function handleLastPersonsFulfilled(event: LastPersonsFulfilled): void {
  let id = event.params.requestId.toHex()
  let person = new PersonActivity(id);
  person.timestamp = event.block.timestamp;
  person.count = event.params.lastPersons
  person.save();
}

export function handleLastDevicesFulfilled(event: LastDevicesFulfilled): void {
  let id = event.params.requestId.toHex()
  let device = new DeviceActivity(id);
  device.timestamp = event.block.timestamp;
  device.count = event.params.lastDevices
  device.save();
}
