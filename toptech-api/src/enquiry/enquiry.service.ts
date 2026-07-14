import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Enquiry } from './enquiry.model';
import { CreateEnquiryDto } from './dto/create-enquiry.dto';
import { UpdateEnquiryDto } from './dto/update-enquiry.dto';
import { Employee } from '../employee/employee.model';
import { Service } from '../service/service.model';
import { EmployeeDevice } from '../employee-device/employee-device.model';

@Injectable()
export class EnquiryService {
  constructor(
    @InjectModel(Enquiry)
    private readonly enquiryModel: typeof Enquiry,
    @InjectModel(EmployeeDevice)
    private readonly employeeDeviceModel: typeof EmployeeDevice,
  ) { }

  async create(createEnquiryDto: CreateEnquiryDto): Promise<Enquiry> {
    const dateStr = createEnquiryDto.date || new Date().toLocaleDateString('en-GB', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    });
    const created = await this.enquiryModel.create({
      ...createEnquiryDto,
      date: dateStr,
    } as any);

    if (created.assignedToId) {
      this.triggerPushNotification(
        created.assignedToId,
        created.assignedById,
        created.client,
      );
    }

    return this.findOne(created.id);
  }

  async findAll(): Promise<Enquiry[]> {
    return this.enquiryModel.findAll({
      include: [
        { model: Employee, as: 'assignedEmployee', attributes: ['id', 'name'] },
        { model: Employee, as: 'creatorEmployee', attributes: ['id', 'name'] },
        { model: Service, attributes: ['id', 'serviceName'] },
      ],
      order: [['id', 'DESC']],
    });
  }

  async findOne(id: number): Promise<Enquiry> {
    const enquiry = await this.enquiryModel.findByPk(id, {
      include: [
        { model: Employee, as: 'assignedEmployee', attributes: ['id', 'name'] },
        { model: Employee, as: 'creatorEmployee', attributes: ['id', 'name'] },
        { model: Service, attributes: ['id', 'serviceName'] },
      ],
    });
    if (!enquiry) {
      throw new NotFoundException(`Enquiry with ID ${id} not found`);
    }
    return enquiry;
  }

  async update(id: number, updateEnquiryDto: UpdateEnquiryDto): Promise<Enquiry> {
    const enquiry = await this.findOne(id);
    const oldAssignedToId = enquiry.assignedToId;
    const oldReminderDate = enquiry.reminderDate;
    await enquiry.update(updateEnquiryDto as any);

    if (updateEnquiryDto.assignedToId && updateEnquiryDto.assignedToId !== oldAssignedToId) {
      this.triggerPushNotification(
        updateEnquiryDto.assignedToId,
        updateEnquiryDto.assignedById || enquiry.assignedById,
        updateEnquiryDto.client || enquiry.client,
      );
    }

    if (updateEnquiryDto.reminderDate && updateEnquiryDto.reminderDate !== oldReminderDate) {
      const reminderTime = new Date(updateEnquiryDto.reminderDate);
      const now = new Date();
      if (reminderTime > now) {
        this.triggerPushNotification(
          updateEnquiryDto.assignedToId || enquiry.assignedToId,
          updateEnquiryDto.assignedById || enquiry.assignedById,
          updateEnquiryDto.client || enquiry.client,
          updateEnquiryDto.reminderDate,
        );
      }
    }

    return this.findOne(id);
  }

  async remove(id: number): Promise<void> {
    const enquiry = await this.findOne(id);
    await enquiry.destroy();
  }

  private async triggerPushNotification(
    assignedToId: number,
    assignedById: number,
    clientName: string,
    sendAfter?: string,
  ) {
    try {
      const assignee = await Employee.findByPk(assignedToId);
      const assigner = assignedById ? await Employee.findByPk(assignedById) : null;

      if (!assignee) return;

      const isScheduled = !!sendAfter;
      const title = isScheduled ? '⏰ Follow-up Reminder' : '📋 New Lead Assigned';
      const message = isScheduled
        ? `Follow-up reminder for client "${clientName}"`
        : `You have new enquiry from "${clientName}"`;

      // OneSignal Send via REST API
      const appId = process.env.ONESIGNAL_APP_ID || 'e1ad6618-6f77-41d8-a0fc-014cb1585b5f';
      const apiKey = process.env.ONESIGNAL_REST_API_KEY || 'os_v2_app_4gwwmgdpo5a5rih4afglcwc3l6egadrpmxjeku56laydo6naf33tq2dsoaqdanjqcqiqtvhd26hqkhbiamxo2jp64hff7b4d2gomd2q';

      // Fetch ALL registered devices for this assignee
      const devices = await this.employeeDeviceModel.findAll({
        where: { employeeId: assignedToId },
        attributes: ['onesignalPlayerId'],
      });

      const playerIds = devices.map(d => d.onesignalPlayerId);
      console.log(`[OneSignal] Sending to employee #${assignedToId} (${assignee.name}) — ${playerIds.length} device(s): ${playerIds.join(', ')}`);

      const payload: any = {
        app_id: appId,
        headings: { en: title },
        contents: { en: message },
      };

      if (playerIds.length > 0) {
        // Send to ALL registered devices at once
        payload.include_player_ids = playerIds;
      } else {
        // Fallback: target via OneSignal external user ID
        payload.include_external_user_ids = [assignee.id.toString()];
        payload.channel_for_external_user_ids = 'push';
      }

      if (sendAfter) {
        // sendAfter arrives as "YYYY-MM-DDTHH:MM:SS+05:30" (IST)
        // OneSignal's send_after needs "YYYY-MM-DD HH:MM:SS GMT+0530" format in IST.
        const istDate = new Date(sendAfter);
        const pad = (n: number) => n.toString().padStart(2, '0');
        const istOffset = 330 * 60 * 1000; // 5h30m in ms
        const istMs = istDate.getTime() + istOffset;
        const d = new Date(istMs);
        const formatted = `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}-${pad(d.getUTCDate())} ${pad(d.getUTCHours())}:${pad(d.getUTCMinutes())}:00 GMT+0530`;
        payload.send_after = formatted;
      }

      const res = await fetch('https://onesignal.com/api/v1/notifications', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Basic ${apiKey}`,
        },
        body: JSON.stringify(payload),
      });
      const responseJson = await res.json();
      console.log('OneSignal Notification Sent:', responseJson);
    } catch (e) {
      console.error('Failed to trigger OneSignal notification:', e.message);
    }
  }
}
