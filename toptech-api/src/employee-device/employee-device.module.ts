import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { EmployeeDevice } from './employee-device.model';

@Module({
  imports: [SequelizeModule.forFeature([EmployeeDevice])],
  exports: [SequelizeModule],
})
export class EmployeeDeviceModule {}
