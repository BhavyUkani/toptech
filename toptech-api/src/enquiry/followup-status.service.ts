import { Injectable, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { FollowupStatus } from './followup-status.model';
import { CreateFollowupStatusDto } from './dto/create-followup-status.dto';

@Injectable()
export class FollowupStatusService implements OnModuleInit {
  constructor(
    @InjectModel(FollowupStatus)
    private readonly statusModel: typeof FollowupStatus,
  ) {}

  async onModuleInit() {
    // Seed default statuses if table is empty
    const count = await this.statusModel.count();
    if (count === 0) {
      const defaults = ['Pending', 'Quotation Asked', 'Quotation Send', 'Deal Closed'];
      for (let i = 0; i < defaults.length; i++) {
        await this.statusModel.create({ name: defaults[i], displayOrder: i } as any);
      }
    }
  }

  async findAll(): Promise<FollowupStatus[]> {
    return this.statusModel.findAll({ order: [['displayOrder', 'ASC']] });
  }

  async create(dto: CreateFollowupStatusDto): Promise<FollowupStatus> {
    const maxOrder = await this.statusModel.max('displayOrder') as number;
    const nextOrder = (maxOrder || 0) + 1;
    return this.statusModel.create({ name: dto.name, displayOrder: nextOrder } as any);
  }

  async update(id: number, name: string): Promise<FollowupStatus | null> {
    const status = await this.statusModel.findByPk(id);
    if (status) {
      await status.update({ name });
    }
    return status;
  }

  async updateOrders(ordersList: { id: number; displayOrder: number }[]): Promise<void> {
    for (const item of ordersList) {
      await this.statusModel.update(
        { displayOrder: item.displayOrder },
        { where: { id: item.id } }
      );
    }
  }

  async remove(id: number): Promise<void> {
    const status = await this.statusModel.findByPk(id);
    if (status) {
      await status.destroy();
    }
  }
}
