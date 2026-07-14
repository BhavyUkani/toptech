import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Service } from './service.model';

@Injectable()
export class ServiceService {
  constructor(
    @InjectModel(Service)
    private readonly serviceModel: typeof Service,
  ) {}

  async create(serviceName: string): Promise<Service> {
    return this.serviceModel.create({ serviceName } as any);
  }

  async findAll(): Promise<Service[]> {
    return this.serviceModel.findAll({
      order: [['serviceName', 'ASC']],
    });
  }

  async findOne(id: number): Promise<Service> {
    const service = await this.serviceModel.findByPk(id);
    if (!service) {
      throw new NotFoundException(`Service with ID ${id} not found`);
    }
    return service;
  }

  async remove(id: number): Promise<void> {
    const service = await this.findOne(id);
    await service.destroy();
  }

  async update(id: number, serviceName: string): Promise<Service> {
    const service = await this.findOne(id);
    await service.update({ serviceName });
    return service;
  }
}
