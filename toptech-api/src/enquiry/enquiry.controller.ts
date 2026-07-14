import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, ParseIntPipe, Request } from '@nestjs/common';
import { EnquiryService } from './enquiry.service';
import { CreateEnquiryDto } from './dto/create-enquiry.dto';
import { UpdateEnquiryDto } from './dto/update-enquiry.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('enquiries')
@UseGuards(JwtAuthGuard)
export class EnquiryController {
  constructor(private readonly enquiryService: EnquiryService) {}

  @Post()
  create(@Body() createEnquiryDto: CreateEnquiryDto, @Request() req) {
    const creatorId = req.user.id;
    return this.enquiryService.create({
      ...createEnquiryDto,
      assignedById: creatorId,
    });
  }

  @Get()
  findAll() {
    return this.enquiryService.findAll();
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.enquiryService.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateEnquiryDto: UpdateEnquiryDto,
    @Request() req,
  ) {
    // Only update assignedById when reassigning — follow-up/reminder patches
    // should NOT change the assigner, so the reminder fires to the correct assignee.
    const patchData: any = { ...updateEnquiryDto };
    if (updateEnquiryDto.assignedToId) {
      patchData.assignedById = req.user.id;
    }
    return this.enquiryService.update(id, patchData);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.enquiryService.remove(id);
  }
}
