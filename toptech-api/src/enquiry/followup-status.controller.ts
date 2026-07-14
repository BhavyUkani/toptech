import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { FollowupStatusService } from './followup-status.service';
import { CreateFollowupStatusDto } from './dto/create-followup-status.dto';
import { UpdateFollowupStatusDto } from './dto/update-followup-status.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('followup-statuses')
@UseGuards(JwtAuthGuard)
export class FollowupStatusController {
  constructor(private readonly statusService: FollowupStatusService) {}

  @Get()
  async findAll() {
    return this.statusService.findAll();
  }

  @Post()
  async create(@Body() createDto: CreateFollowupStatusDto) {
    return this.statusService.create(createDto);
  }

  @Patch(':id')
  async update(@Param('id') id: string, @Body() updateDto: UpdateFollowupStatusDto) {
    return this.statusService.update(+id, updateDto.name);
  }

  @Post('reorder')
  async reorder(@Body() body: { orders: { id: number; displayOrder: number }[] }) {
    await this.statusService.updateOrders(body.orders);
    return { success: true };
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    await this.statusService.remove(+id);
    return { success: true };
  }
}
