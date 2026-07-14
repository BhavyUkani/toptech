import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { Enquiry } from './enquiry.model';
import { FollowupStatus } from './followup-status.model';
import { EnquiryService } from './enquiry.service';
import { FollowupStatusService } from './followup-status.service';
import { EnquiryController } from './enquiry.controller';
import { FollowupStatusController } from './followup-status.controller';
import { EmployeeDeviceModule } from '../employee-device/employee-device.module';

@Module({
  imports: [SequelizeModule.forFeature([Enquiry, FollowupStatus]), EmployeeDeviceModule],
  providers: [EnquiryService, FollowupStatusService],
  controllers: [EnquiryController, FollowupStatusController],
  exports: [EnquiryService, FollowupStatusService],
})
export class EnquiryModule {}
